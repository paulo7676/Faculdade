defmodule Main do
  def intervp(m,n) do


    if m == n || m-n == 0 || m-n == 1 do
      1
    else
      (m-1) * intervp(m-1,n)
    end
  end
end
IO.puts(Main.intervp(5,2))
