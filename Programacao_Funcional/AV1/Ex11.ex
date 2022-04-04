defmodule Main do

  def min3(x, y, z) do

    if x <= y && x <= z do
      x
    else
      if y <= z do
        y
      else
        z
      end
    end
  end
end
IO.puts(Main.min3(3, 2, 1))
IO.puts(Main.min3(2, 10, 4))
IO.puts(Main.min3(5, 3, 5))
IO.puts(Main.min3(2, 3, 2))
