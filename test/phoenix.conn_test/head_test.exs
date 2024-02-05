defmodule MultiversesHttpTest.Phoenix.ConnTest.HeadTest do
  use ConnCase, async: true

  setup do
    Multiverses.shard(Http)
    {:ok, conn: build_conn()}
  end

  describe "when you send an arbitrary request to head/2" do
    test "it returns the multiverses id with request struct", %{conn: conn} do
      assert %{resp_headers: headers} = head(conn, "/")

      assert {"x-multiverse-response", "#{Multiverses.id(Http)}"} == List.keyfind!(headers, "x-multiverse-response", 0)
    end
  end
end