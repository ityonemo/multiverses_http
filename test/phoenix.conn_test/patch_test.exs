defmodule MultiversesHttpTest.Phoenix.ConnTest.PatchTest do
  use ConnCase, async: true

  setup do
    Multiverses.shard(Http)
    {:ok, conn: build_conn()}
  end

  describe "when you send an arbitrary request to patch/2" do
    test "it returns the multiverses id with request struct", %{conn: conn} do
      assert %{resp_body: body} = patch(conn, "/")
      assert body == "#{Multiverses.id(Http)}"
    end
  end
end
