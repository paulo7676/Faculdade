defmodule Main do

  def plus_pi_div_e(c) when is_integer(c) do
    pi = 3.14
    e = 2.71828
    (c * pi) / e
  end

end
IO.puts(Main.plus_pi_div_e(2))
