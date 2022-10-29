defmodule MultiversesHttpTest.Router do
  use Plug.Router

  plug(Multiverses.Plug)

  plug(:match)
  plug(:dispatch)

  head "/" do
    conn
    |> put_resp_header("x-multiverse-response", "#{Multiverses.id(Http)}")
    |> send_resp(200, "")
  end

  match "/" do
    send_resp(conn, 200, "#{Multiverses.id(Http)}")
  end
end
