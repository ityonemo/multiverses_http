defmodule MultiversesHttpTest do
  use ExUnit.Case
  doctest MultiversesHttp

  test "greets the world" do
    assert MultiversesHttp.hello() == :world
  end
end
