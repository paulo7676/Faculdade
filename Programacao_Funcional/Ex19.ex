defmodule Main do
  def coprimo(x,y) do
    if rem(y,x) == 1 do
      true
    else
      false
    end
  end
end
IO.puts(Main.coprimo(13,27))
IO.puts(Main.coprimo(13,26))
IO.puts(Main.coprimo(2,7))
