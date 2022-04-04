defmodule Main do

  def sao_iguais(a,b) do
    if a == b do
      true
    else
      false
    end
  end
end
IO.puts(Main.sao_iguais(3,3))
IO.puts(Main.sao_iguais(3,4))
