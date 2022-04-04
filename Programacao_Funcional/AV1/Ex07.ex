defmodule Main do

  def k2f(k) when is_number(k) do

    (k - 273.15) * 9/5 + 32

  end
end
IO.puts(Main.k2f(21))
IO.puts(Main.k2f(123))
