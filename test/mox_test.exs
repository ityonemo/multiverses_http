defmodule MultiversesTest.MoxTest do
  use ExUnit.Case, async: true

  @req Multiverses.Req

  setup do
    Multiverses.shard(Http)
  end

  describe "when you make a request" do
    test "mox is respected" do
      Mox.expect(Mocked, :value, fn -> "value" end)

      assert {:ok, %{body: "value"}} = @req.get("http://localhost:6001/mox")
    end
  end
end
