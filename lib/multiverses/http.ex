defmodule Multiverses.Http do
  use GenServer

  @this {:global, __MODULE__}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @this)
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
    |> List.first
  end

  defp get_registered_impl(id, callers, _from, table) do
    get_registered(id) || :ets.insert(table, {id, callers})
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
    |> List.first
  end

  defp get_callers_impl(id, _from, table) do
    {:reply, get_callers(table, id), table}
  end

  def adopt_callers(id) do
    Process.put(:"$callers", get_callers(id))
  end

  def handle_call({:get_registered, id, callers}, from, table), do: get_registered_impl(id, callers, from, table)
  def handle_call({:register, id, callers}, from, table), do: register_impl(id, callers, from, table)
  def handle_call({:get_callers, id}, from, table), do: get_callers_impl(id, from, table)
end
