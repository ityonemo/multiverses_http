defmodule MultiversesHttpTest.Req.RequestTest do
  use ExUnit.Case, async: true

  setup do
    Multiverses.shard(Http)
  end

  @req Multiverses.Req

  describe "when you send an arbitrary request to request/1" do
    test "it returns the multiverses id" do
      request = @req.new(url: "http://localhost:6001/")
      assert {:ok, %{body: body}} = @req.request(request)
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
