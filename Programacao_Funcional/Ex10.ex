defmodule Main do

  def min(x, y) do

    if x <= y do
      x
    else
      y
    end

  end
end
IO.puts(Main.min(3, 2))
IO.puts(Main.min(1, 10))
IO.puts(Main.min(5, 5))
