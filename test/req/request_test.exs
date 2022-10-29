defmodule MultiversesHttpTest.Req.RequestTest do
  use ExUnit.Case, async: true

  setup do
    Multiverses.shard(Http)
  end

  @req Multiverses.Req

  describe "when you send an arbitrary request to request/1" do
    test "it returns the multiverses id with request struct" do
      request = @req.new(url: "http://localhost:6001/")
      assert {:ok, %{body: body}} = @req.request(request)
      assert body == "#{Multiverses.id(Http)}"
    end

    test "it returns the multiverses id with options" do
      assert {:ok, %{body: body}} = @req.request(url: "http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to request/2" do
    test "it returns the multiverses id with request struct" do
      request = @req.new(url: "http://localhost:6001/")
      assert {:ok, %{body: body}} = @req.request(request, [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to request!/1" do
    test "it returns the multiverses id with request struct" do
      request = @req.new(url: "http://localhost:6001/")
      assert %{body: body} = @req.request!(request)
      assert body == "#{Multiverses.id(Http)}"
    end

    test "it returns the multiverses id with options" do
      assert %{body: body} = @req.request!(url: "http://localhost:6001/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end

  describe "when you send an arbitrary request to request!/2" do
    test "it returns the multiverses id with request struct" do
      request = @req.new(url: "http://localhost:6001/")
      assert %{body: body} = @req.request!(request, [])
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
