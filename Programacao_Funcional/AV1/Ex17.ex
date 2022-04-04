defmodule Main do
  def potencia_de_2(0), do: 1
  def potencia_de_2(1), do: 2
  def potencia_de_2(i), do: 2 * potencia_de_2(i-1)
end
IO.puts(Main.potencia_de_2(0))
IO.puts(Main.potencia_de_2(1))
IO.puts(Main.potencia_de_2(5))
