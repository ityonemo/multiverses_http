defmodule MultiversesTest.ClusterTest do
  use ExUnit.Case, async: true

  @req Multiverses.Req

  setup do
    Multiverses.shard(Http)
  end

  describe "when you make a request" do
    test "the cluster respects your multiverse id" do
      assert {:ok, %{body: body}} = @req.get("http://localhost:6002/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
