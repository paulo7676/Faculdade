defmodule Main do

  def somat2(n) when n > 0 do

    if n == 1 do
      n
    else
      n + somat2(n-1)
    end

  end
end
IO.puts(Main.somat2(5))
