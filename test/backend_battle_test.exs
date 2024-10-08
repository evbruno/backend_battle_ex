defmodule BackendBattleTest do
  use ExUnit.Case
  doctest BackendBattle

  test "greets the world" do
    assert BackendBattle.hello() == :world
  end
end
