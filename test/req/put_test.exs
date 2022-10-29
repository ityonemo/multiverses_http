defmodule MultiversesHttpTest.Req.PutTest do
  use ExUnit.Case, async: true

  setup do
    Multiverses.shard(Http)
  end

  @req Multiverses.Req

  describe "when you send an arbitrary request to put/1" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{body: body}} = @req.put("http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to put/2" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{body: body}} = @req.put("http://localhost:6001/", [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to put!/1" do
    test "it returns the multiverses id with request struct" do
      assert %{body: body} = @req.put!("http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to put!/2" do
    test "it returns the multiverses id with request struct" do
      assert %{body: body} = @req.put!("http://localhost:6001/", [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
