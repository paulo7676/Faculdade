defmodule Main do

  def c2k(c) when is_number(c)  do
    c + 273.15
  end

end
IO.puts(Main.c2k(30))
IO.puts(Main.c2k(37.2))
