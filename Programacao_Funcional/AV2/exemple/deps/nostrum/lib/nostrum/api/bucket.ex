defmodule Nostrum.Api.Bucket do
  @moduledoc false

  alias Nostrum.Util

  def update_bucket(route, remaining, reset_time, latency) do
    :ets.insert(:ratelimit_buckets, {route, remaining, reset_time, latency})
  end

  def lookup_bucket(route) do
    route_time = :ets.lookup(:ratelimit_buckets, route)
    global_time = :ets.lookup(:ratelimit_buckets, "GLOBAL")

    Enum.max_by([route_time, global_time], fn info ->
      case info do
        [] -> -1
        [{_route, _remaining, reset_time, _latency}] -> reset_time
      end
    end)
  end

  def update_remaining(route, remaining) do
    :ets.update_element(:ratelimit_buckets, route, {2, remaining})
  end

  def delete_bucket(route) do
    :ets.delete(:ratelimit_buckets, route)
  end

  def get_ratelimit_timeout(route) do
    case lookup_bucket(route) do
      [] ->
        :now

      [{route, remaining, _reset_time, _latency}] when remaining > 0 ->
        update_remaining(route, remaining - 1)
        :now

      [{_route, _remaining, reset_time, latency}] ->
        reset_time - Util.now() + latency
    end
  end
end
