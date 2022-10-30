defmodule Multiverses.Plug do
  @moduledoc """
  A module `Plug` that intercepts an http request and temporarily assigns the
  callers stack of the http request to the `Http` shard stored in the
  `x-multiverse-id` header of the http request
  """

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

        Conn.register_before_send(conn, &restore_callers(&1, old_callers))

      [] ->
        conn
    end
  end

  defp restore_callers(conn, old_callers) do
    if old_callers do
      Process.put(:"$callers", old_callers)
    else
      Process.delete(:"$callers")
    end

    conn
  end
end
