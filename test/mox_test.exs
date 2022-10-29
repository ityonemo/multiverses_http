defmodule MultiversesTest.MoxTest do
  use ExUnit.Case, async: true

  @req Multiverses.Req

  setup do
    Multiverses.shard(Http)
  end

  describe "when you send an arbitrary request to the peer using get/1" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{body: body}} = @req.get("http://localhost:6002/", max_retries: 1)
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
