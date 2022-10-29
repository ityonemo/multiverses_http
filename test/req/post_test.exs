defmodule MultiversesHttpTest.Req.PostTest do
  use ExUnit.Case, async: true

  setup do
    Multiverses.shard(Http)
  end

  @req Multiverses.Req

  describe "when you send an arbitrary request to post/1" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{body: body}} = @req.post("http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to post/2" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{body: body}} = @req.post("http://localhost:6001/", [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to post!/1" do
    test "it returns the multiverses id with request struct" do
      assert %{body: body} = @req.post!("http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to post!/2" do
    test "it returns the multiverses id with request struct" do
      assert %{body: body} = @req.post!("http://localhost:6001/", [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
