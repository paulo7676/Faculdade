defmodule Main do

  def metros2centímetros(m) when is_number(m) do
    m * 100
  end

end
IO.puts(Main.metros2centímetros(1.60))
IO.puts(Main.metros2centímetros(2))
