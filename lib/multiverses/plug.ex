defmodule Multiverses.Plug do
  @behaviour Plug
  alias Plug.Conn

  def init(_), do: []

  def call(conn, _) do
    case Conn.get_req_header(conn, "x-multiverse-id") do
      [multiverse_id] ->
        multiverse_id
        |> String.to_integer
        |> Multiverses.Http.adopt_callers
      [] -> []
    end
    conn
  end
end
