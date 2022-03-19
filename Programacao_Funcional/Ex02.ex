defmodule Main do

  def c2f(c) do
    ((c * 9) / 5) + 32
  end

end
IO.puts(Main.c2f(12))
