defmodule Carpeado.Consumer do
  #consumidor de eventos do discord
  #mix run --no halt


  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      String.starts_with?(msg.content, "!coffe") -> coffee(msg)
      String.starts_with?(msg.content, "!wiki ") -> wiki(msg)
      String.starts_with?(msg.content, "!feriados") -> feriados(msg)
      true -> :ignore
    end
  end

  def coffee(msg) do
    resp = HTTPoison.get!("https://coffee.alexflipnote.dev/random.json")
    {:ok, map} = Poison.decode(resp.body)
    Api.create_message(msg.channel_id, map["file"])
  end

  def wiki(msg) do
    aux = String.split(msg.content, " ",parts: 2)

    wikis = Enum.fetch!(aux,1)
    wiki_s = String.replace(wikis," ","_")
    resp = HTTPoison.get!("https://pt.wikipedia.org/api/rest_v1/page/summary/#{wiki_s}?redirect=true")


    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        informacao = map["extract"]
        imagem = map["thumbnail"]["source"]
        Api.create_message(msg.channel_id, imagem)
        Api.create_message(msg.channel_id, informacao)
      404 ->
        Api.create_message(msg.channel_id, "Nao Conseguimos encontrar informações sobre #{wikis} tente novamente")
    end
  end

  def feriados(msg) do
    comando = msg.content
    aux = :calendar.local_time()
    dia = elem(elem(aux, 0),2)
    mes = elem(elem(aux, 0),1)
    ano = elem(elem(aux, 0),0)

    resp = HTTPoison.get!(
      "https://calendarific.com/api/v2/holidays?api_key=9b19fb821d05703828bdf22b96dfd0e678e802e5&country=BR&year=#{ano}")
    {:ok, map} = Poison.decode(resp.body, keys: :atoms)

    Api.create_message(msg.channel_id, "Em #{ano} ainda temos feriados nos dias:")
    for n <- map.response.holidays do
      if n.date.datetime.month - mes > 0 && n.date.datetime.day - dia > 0 do
        proximo_feriado = "#{n.date.datetime.day}/#{n.date.datetime.month}/#{ano}"
        Api.create_message(msg.channel_id, proximo_feriado)
      end
    end
  end

  def teste(msg) do
    resp = HTTPoison.get!("https://nekos.best/api/v2/kiss")
    {:ok, map} = Poison.decode(resp.body)
    a = map["results"]
    Api.create_message(msg.channel_id, Enum.at(map["results"],0)["url"])
  end

  def handle_event(_event) do
    :noop
  end
end
