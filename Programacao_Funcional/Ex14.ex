defmodule Main do

  def fatduplo(n) when n > 1, do: n * fatduplo(n-2)
  def fatduplo(1), do: 1
  def fatduplo(0), do: 1
end
IO.puts(Main.fatduplo(7))
IO.puts(Main.fatduplo(6))
IO.puts(Main.fatduplo(2))
