defmodule Main do

  def c2f(c) when is_number(c) do
    ((c * 9) / 5) + 32
  end

end
IO.puts(Main.c2f(12))
IO.puts(Main.c2f('12'))
