defmodule Main do
  def hanoi(0), do: 0
  def hanoi(1), do: 1
  def hanoi(i), do: 2 * hanoi(i-1) + 1
end
IO.puts(Main.hanoi(3))
