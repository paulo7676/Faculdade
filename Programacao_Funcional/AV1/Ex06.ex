defmodule Main do

  def cubo(x) when is_number(x) do

    x**3

  end
end
IO.puts(Main.cubo(2))
IO.puts(Main.cubo(3))
