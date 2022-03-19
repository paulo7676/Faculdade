defmodule Main do
  def somat3(n), do: somat3(n,1)
  def somat3(1,b), do: b
  def somat3(a,b), do: somat3(a-1,b+a)

end
IO.puts(Main.somat3(4))
IO.puts(Main.somat3(6))
