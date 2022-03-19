defmodule Main do
  def hms_tempo(h,m,s) do

    if (h > 24 || h < 1) || (m > 59 || m < 1) || (s > 59 || s < 1) do
      "algum dado fornecido está incorreto"

    else
      (h * 3600) + (m * 60) + s
    end
  end
end
IO.puts(Main.hms_tempo(9,32,50))
IO.puts(Main.hms_tempo(3,0,0))
