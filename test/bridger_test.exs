defmodule BridgerTest do
  use ExUnit.Case
  doctest Bridger

  test "greets the world" do
    assert Bridger.hello() == :world
  end
end
