defmodule ExempleTest do
  use ExUnit.Case
  doctest Exemple

  test "greets the world" do
    assert Exemple.hello() == :world
  end
end
