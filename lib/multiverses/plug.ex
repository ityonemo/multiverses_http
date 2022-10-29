defmodule Multiverses.Plug do
  @behaviour Plug
  alias Plug.Conn

  def init(_), do: []

  def call(conn, _) do
    case Conn.get_req_header(conn, "x-multiverse-id") do
      [multiverse_id] ->
        old_callers = Process.get(:"$callers")

        multiverse_id
        |> String.to_integer()
        |> Multiverses.Http.adopt_callers()

        Conn.register_before_send(conn, fn conn ->
          if old_callers do
            Process.put(:"$callers", old_callers)
          else
            Process.delete(:"$callers")
          end

          conn
        end)

      [] ->
        conn
    end
  end
end
