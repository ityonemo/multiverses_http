defmodule MultiversesHttpTest.Req.HeadTest do
  use ExUnit.Case, async: true

  setup do
    Multiverses.shard(Http)
  end

  @req Multiverses.Req

  describe "when you send an arbitrary request to head/1" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{headers: headers}} = @req.head("http://localhost:6001/")
      assert {"x-multiverse-response", "#{Multiverses.id(Http)}"} == List.keyfind!(headers, "x-multiverse-response", 0)
    end
  end

  describe "when you send an arbitrary request to head/2" do
    test "it returns the multiverses id with request struct" do
      assert {:ok, %{headers: headers}} = @req.head("http://localhost:6001/", [])
      assert {"x-multiverse-response", "#{Multiverses.id(Http)}"} == List.keyfind!(headers, "x-multiverse-response", 0)
    end
  end

  describe "when you send an arbitrary request to head!/1" do
    test "it returns the multiverses id with request struct" do
      assert %{headers: headers} = @req.head!("http://localhost:6001/")
      assert {"x-multiverse-response", "#{Multiverses.id(Http)}"} == List.keyfind!(headers, "x-multiverse-response", 0)
    end
  end

  describe "when you send an arbitrary request to head!/2" do
    test "it returns the multiverses id with request struct" do
      assert %{headers: headers} = @req.head!("http://localhost:6001/", [])
      assert {"x-multiverse-response", "#{Multiverses.id(Http)}"} == List.keyfind!(headers, "x-multiverse-response", 0)
    end
  end
end
