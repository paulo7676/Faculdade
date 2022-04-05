defmodule Nostrum.Voice.Audio do
  @moduledoc false

  require Logger

  alias Nostrum.Error.VoiceError
  alias Nostrum.Struct.VoiceState
  alias Nostrum.Util
  alias Nostrum.Voice
  alias Nostrum.Voice.Ports

  @encryption_mode "xsalsa20_poly1305"
  @samples_per_frame 960
  @usec_per_frame 20_000
  # Default value
  @frames_per_burst 10

  # Executables
  @ffmpeg "ffmpeg"
  @ytdl "youtube-dl"
  @streamlink "streamlink"

  def encryption_mode, do: @encryption_mode

  # How many consecutive packets to send before resting
  def frames_per_burst,
    do: Application.get_env(:nostrum, :audio_frames_per_burst, @frames_per_burst)

  def rtp_header(%VoiceState{} = voice) do
    <<
      0x80::8,
      0x78::8,
      voice.rtp_sequence::16,
      voice.rtp_timestamp::32,
      voice.ssrc::32
    >>
  end

  def encrypt_packet(%VoiceState{} = voice, data) do
    header = rtp_header(voice)
    # 12 byte header + 12 null bytes
    nonce = header <> <<0::96>>
    header <> Kcl.secretbox(data, nonce, voice.secret_key)
  end

  def open_udp do
    {:ok, socket} =
      :gen_udp.open(0, [
        :binary,
        {:active, false},
        {:reuseaddr, true}
      ])

    socket
  end

  def get_rtp_packet(%VoiceState{secret_key: key, udp_socket: socket} = v) do
    {:ok, {_ip, _port, payload}} = :gen_udp.recv(socket, 1024)

    case payload do
      # Skip RTCP packets
      <<2::2, 0::1, 1::5, 201::8, _rest::binary>> ->
        get_rtp_packet(v)

      <<header::96, data::binary>> ->
        nonce = <<header::96, 0::96>>
        {<<header::96>>, Kcl.secretunbox(data, nonce, key)}
    end
  end

  def get_unique_rtp_packets(v, num), do: unique_rtp(v, num, [], MapSet.new())

  def unique_rtp(_v, 0, packets, _set), do: Enum.reverse(packets)

  def unique_rtp(v, num_remaining, packets, set) do
    packet = get_rtp_packet(v)

    # Check for and remove duplicate RTP packets
    if MapSet.member?(set, packet) do
      # Duplicate was found
      unique_rtp(v, num_remaining, packets, set)
    else
      unique_rtp(v, num_remaining - 1, [packet | packets], MapSet.put(set, packet))
    end
  end

  def start_player(voice) do
    take_nap()
    player_loop(voice, _init? = true, _source = get_source(voice))
  end

  def resume_player(voice) do
    player_loop(voice, _init? = false, _source = get_source(voice))
  end

  def player_loop(voice, init?, source) do
    t1 = Util.usec_now()
    voice = try_send_data(voice, init?, source)
    t2 = Util.usec_now()

    take_nap(t2 - t1)

    player_loop(voice, false, source)
  end

  def take_nap(diff \\ 0) do
    ((@usec_per_frame * frames_per_burst() - diff) / 1000)
    |> trunc()
    |> max(0)
    |> Process.sleep()
  end

  def get_source(%VoiceState{ffmpeg_proc: nil, raw_audio: raw_audio}), do: raw_audio

  def get_source(%VoiceState{ffmpeg_proc: ffmpeg_proc}), do: Ports.get_stream(ffmpeg_proc)

  def try_send_data(%VoiceState{} = voice, init?, source) do
    wait = if(init?, do: Application.get_env(:nostrum, :audio_timeout, 20_000), else: 500)
    {:ok, watchdog} = :timer.apply_after(wait, __MODULE__, :on_stall, [voice])

    {voice, done} =
      source
      |> Enum.take(frames_per_burst())
      |> send_frames(voice)

    :timer.cancel(watchdog)

    if done,
      do: on_complete(voice, init?),
      else: voice
  end

  def try_send_data(_, _), do: :ok

  def send_frames(frames, %VoiceState{} = voice) do
    voice =
      Enum.reduce(frames, voice, fn f, v ->
        :gen_udp.send(
          v.udp_socket,
          v.ip |> ip_to_tuple(),
          v.port,
          encrypt_packet(v, f)
        )

        %{
          v
          | rtp_sequence: v.rtp_sequence + 1,
            rtp_timestamp: v.rtp_timestamp + @samples_per_frame
        }
      end)

    {Voice.update_voice(voice.guild_id,
       rtp_sequence: voice.rtp_sequence,
       rtp_timestamp: voice.rtp_timestamp,
       # If using raw audio and it isn't stateful, update its state manually
       raw_audio:
         if not is_nil(voice.raw_audio) and not voice.raw_stateful do
           Enum.slice(voice.raw_audio, frames_per_burst()..-1)
         else
           voice.raw_audio
         end
     ), length(frames) < frames_per_burst()}
  end

  def spawn_youtubedl(url) do
    res =
      Ports.execute(
        Application.get_env(:nostrum, :youtubedl, @ytdl),
        [
          ["-f", "bestaudio"],
          ["-o", "-"],
          ["-q"],
          [url]
        ]
        |> List.flatten()
      )

    case res do
      {:error, reason} ->
        raise(VoiceError, reason: reason, executable: @ytdl)

      {:ok, pid} ->
        pid
    end
  end

  def spawn_streamlink(url) do
    res =
      Ports.execute(
        Application.get_env(:nostrum, :streamlink, @streamlink),
        [
          ["--stdout"],
          ["--quiet"],
          ["--default-stream", "best"],
          ["--url", url]
        ]
        |> List.flatten()
      )

    case res do
      {:error, reason} ->
        raise(VoiceError, reason: reason, executable: @streamlink)

      {:ok, pid} ->
        pid
    end
  end

  def spawn_ffmpeg(input, type \\ :url, options \\ []) do
    {input_url, stdin} =
      case type do
        :url ->
          {input, nil}

        :pipe ->
          {"pipe:0", input}

        :ytdl ->
          {"pipe:0", spawn_youtubedl(input)}

        :stream ->
          {"pipe:0", spawn_streamlink(input)}
      end

    res =
      Ports.execute(
        Application.get_env(:nostrum, :ffmpeg, @ffmpeg),
        [
          ffmpeg_options(options, input_url),
          ["-ac", "2"],
          ["-ar", "48000"],
          ["-f", "s16le"],
          ["-acodec", "libopus"],
          ["-loglevel", "quiet"],
          ["pipe:1"]
        ]
        |> List.flatten(),
        stdin
      )

    case res do
      {:error, reason} ->
        raise(VoiceError, reason: reason, executable: @ffmpeg)

      {:ok, pid} ->
        pid
    end
  end

  def ffmpeg_options(options, input_url) do
    # Volume
    vol_opt =
      case Keyword.get(options, :volume) do
        val when is_number(val) -> [filter: "volume=#{val}"]
        _ -> []
      end

    [
      # Start position
      case Keyword.get(options, :start_pos) do
        nil -> []
        val -> ["-ss", val]
      end,

      # Duration
      case Keyword.get(options, :duration) do
        nil -> []
        val -> ["-t", val]
      end,

      # Realtime Processing
      if(Keyword.get(options, :realtime, true), do: ["-re"], else: []),

      # Input URL
      ["-i", input_url],

      # Filters
      case Keyword.get_values(options ++ vol_opt, :filter) do
        [] -> []
        val -> ["-af", Enum.join(val, ", ")]
      end
    ]
  end

  def on_stall(%VoiceState{} = voice) do
    # Refresh voice state before running checks
    voice = Voice.get_voice(voice.guild_id)

    if VoiceState.playing?(voice) and not is_nil(voice.ffmpeg_proc) do
      Ports.close(voice.ffmpeg_proc)
    end
  end

  def on_complete(%VoiceState{} = voice, timed_out) do
    Voice.update_voice(voice.guild_id, ffmpeg_proc: nil, raw_audio: nil)
    List.duplicate(<<0xF8, 0xFF, 0xFE>>, 5) |> send_frames(voice)
    Voice.set_speaking(voice, false, timed_out)
    Process.exit(voice.player_pid, :stop)
  end

  @doc """
  Because UDP is connectionless, we must discover our machine's external
  IP and port used to communicate via the UDP socket to inform the discord
  voice server where to send incoming voice data. This is a bot library, so
  it's unlikely it will be listening to any incoming voice data, but it's
  here for completeness/correctness.
  """
  def discover_ip(socket, ip, port, ssrc) do
    ip_tuple = ip_to_tuple(ip)

    req_packet =
      <<
        # '1' for request
        1::16,
        # length of rest
        70::16,
        ssrc::32
      >> <>
        (ip |> String.pad_trailing(64, <<0>>)) <>
        <<port::16>>

    :ok = :gen_udp.send(socket, ip_tuple, port, req_packet)
    {:ok, res_packet} = :gen_udp.recv(socket, 74)

    {
      ^ip_tuple,
      ^port,
      <<
        2::16,
        70::16,
        ^ssrc::32,
        my_ip::bitstring-size(512),
        my_port::16
      >>
    } = res_packet

    my_ip = my_ip |> String.trim(<<0>>)
    {my_ip, my_port}
  end

  defp ip_to_tuple(ip) do
    {:ok, ip_tuple} =
      ip
      |> String.to_charlist()
      |> :inet_parse.address()

    ip_tuple
  end
end
