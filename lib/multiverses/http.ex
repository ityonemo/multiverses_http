defmodule Multiverses.Http do
  @moduledoc """
  Multiverses suite to enable isolated HTTP communications over multiverse shards

  ## How to Use

  ### In your Phoenix endpoint:

  ```
  defmodule MyAppWeb.Endpoint do
    #...

    if Mix.env() == :test do
      plug Multiverses.Plug
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

  ```elixir
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
  ```

  ## How it works

  The adapters for the http clients inject the `Multiverses.shard/1` id into
  the http header `x-multiverse-id`.  This is then intercepted by the
  `Multiverses.Plug` module plug in your Endpoint, which then performs a
  lookup to obtain the `:$callers` for the request; this `:$callers` chain
  is then added to the request process dictionary for the duration of the
  http Plug pipeline.

  Because this exchange installs `:$callers` a side effect is that other
  services that are `:$callers` aware, such as `Mox` or `Ecto` will be able
  to see their respective checkouts.

  ## Cluster awareness

  `Multiverses.Http` is tested to work over a BEAM cluster.

  If you spin up a cluster as a part of your tests, you can issue an http
  request to a node that is *not* the node running `ExUnit` and the `:$callers`
  for the request will be remote pids (relative to the request handlers).
  Before proceeding with clustered tests, check to see if the modules that
  depend on this (e.g. `Mox`, `Ecto`) are able to correctly route their sandbox
  checkouts to the correct node in the cluster.

  ## Other backends

  Currently there is support only for the `Req` client library.  If support for
  other libraries is desired, please issue a PR.
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

  @doc """
  obtains the `Multiverses` shard (`Http`) id and registers the current calling
  process `:$callers` stack, if it has not already been registered.

  Generally you would only want to call this function if you are implementing
  an adapter for an HTTP or websocket client library.
  """
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

  @doc false
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

  @doc """
  finds the current process' `Multiverses` shard (`Http`) id and looks up the
  associated `:$callers` chain.  This chain is then imported into as the
  current process' `:$callers` chain.

  Generally you would only want to call this function if you are writing a non-
  `Plug` http handler or a websocket server.  In such a case you should call
  this function immediately after associating the current process with the
  shard using `Multiverses.allow/3` or `Multiverses.allow/2`.
  """
  def adopt_callers(id) do
    Process.put(:"$callers", get_callers(id))
  end

  def handle_call({:get_registered, id, callers}, from, table),
    do: get_registered_impl(id, callers, from, table)

  def handle_call({:register, id, callers}, from, table),
    do: register_impl(id, callers, from, table)

  def handle_call({:get_callers, id}, from, table), do: get_callers_impl(id, from, table)
end
