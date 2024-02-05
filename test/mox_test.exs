defmodule MultiversesTest.MoxTest do
  use ExUnit.Case, async: true

  @req Multiverses.Req

  setup do
    Multiverses.shard(Http)
  end

  describe "when you send a request" do
    test "it also connects Mox" do
      Mox.expect(Mocked, :value, fn -> "value" end)
      assert {:ok, %{body: "value"}} = @req.get("http://localhost:6001/mox")
    end

    test "Mox is respected over the cluster" do
      Mox.expect(Mocked, :value, fn -> "value" end)
      assert {:ok, %{body: "value"}} = @req.get("http://localhost:6002/mox")
    end
  end
end
