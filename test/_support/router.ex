defmodule MultiversesHttpTest.Router do
  use Plug.Router

  plug Multiverses.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "#{Multiverses.id(Http)}")
  end
end
