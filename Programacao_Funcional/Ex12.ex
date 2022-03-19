defmodule Main do
  def somat(1), do: 1
  def somat(n) when n > 0, do: n + somat(n-1)
end
IO.puts(Main.somat(4))
