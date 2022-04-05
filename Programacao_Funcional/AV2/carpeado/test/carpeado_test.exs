defmodule CarpeadoTest do
  use ExUnit.Case
  doctest Carpeado

  test "greets the world" do
    assert Carpeado.hello() == :world
  end
end
