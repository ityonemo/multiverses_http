defmodule Multiverses.Http do
  @moduledoc """
  Multiverses suite to enable isolated HTTP communications over multiverse shards

  ## How to Use

  ### In your Phoenix endpoint:

  ```
  defmodule MyAppWeb.Endpoint do
    #...

    if Mix.env() == :test do
      plug Multiverses.Http
    end

    #...
  end
  ```

  > #### Warning {: .warning}
  >
  > If you anticipate needing to recompile the Endpoint module on the fly you will need a better way to
  > store the build environment, as the Mix module may not be available to the running VM.

  ### In your test (assuming the `Multiverses.Req` adapter is used)

  - declare that your test shards over the Http multiverses name domain.
  - alias `Multiverses.Req` instead of using the `Req` module.

  defmodule MyAppTest do

    alias Multiverses.Req

    @port #....

    setup do
      Multiverses.shard(Http)
    end

    test "some test" do
      result = Req.get("localhost:\#{@port}")
      assert result = #...
    end
  end

  ## How it works

  ## Cluster awareness

  `Multiverses.Http` is tested to work over a BEAM cluster.

  If you spin up a cluster as a part of your tests, you can issue an http
  request to a node that is *not* the node running `ExUnit` and the `:$callers`
  for the request will be remote pids (relative to the request handlers).
  Before proceeding with clustered tests, check to see if the modules that
  depend on this (e.g. `Mox`, `Ecto`) are able to correctly route their sandbox
  checkouts to the correct node in the cluster.
  """

  use GenServer

  @this {:global, __MODULE__}

  def start_link(_) do
    case GenServer.start_link(__MODULE__, [], name: @this) do
      {:error, {:already_started, _}} -> :ignore
      other -> other
    end
  end

  def init(_) do
    table = :ets.new(__MODULE__, [:named_table, :set, :protected, read_concurrency: true])
    {:ok, table}
  end

  def registered_id do
    Http
    |> Multiverses.id()
    |> get_registered()
  end

  defp get_registered(id) do
    if node(:global.whereis_name(__MODULE__)) == node() do
      get_registered(__MODULE__, id) || register(id)
    else
      GenServer.call(@this, {:get_registered, id, get_callers()})
    end
  end

  defp get_registered(table, id) do
    table
    |> :ets.select([{{:"$1", :_}, [{:==, :"$1", {:const, id}}], [:"$1"]}])
    |> List.first()
  end

  defp get_registered_impl(id, callers, _from, table) do
    case :ets.select_count(table, [{{:"$1", :_}, [{:==, :"$1", {:const, id}}], [{{}}]}]) do
      0 ->
        :ets.insert(table, {id, callers})

      _ ->
        []
    end

    {:reply, id, table}
  end

  def register(id) do
    GenServer.call(@this, {:register, id, get_callers()})
  end

  defp register_impl(id, callers, _from, table) do
    :ets.insert(table, {id, callers})
    {:reply, id, table}
  end

  defp get_callers do
    [self() | List.wrap(Process.get(:"$callers"))]
  end

  defp get_callers(id) do
    if node(:global.whereis_name(__MODULE__)) == node() do
      get_callers(__MODULE__, id)
    else
      GenServer.call(@this, {:get_callers, id})
    end
  end

  defp get_callers(table, id) do
    table
    |> :ets.select([{{:"$1", :"$2"}, [{:==, :"$1", {:const, id}}], [:"$2"]}])
    |> List.first()
  end

  defp get_callers_impl(id, _from, table) do
    {:reply, get_callers(table, id), table}
  end

  def adopt_callers(id) do
    Process.put(:"$callers", get_callers(id))
  end

  def handle_call({:get_registered, id, callers}, from, table),
    do: get_registered_impl(id, callers, from, table)

  def handle_call({:register, id, callers}, from, table),
    do: register_impl(id, callers, from, table)

  def handle_call({:get_callers, id}, from, table), do: get_callers_impl(id, from, table)
end
