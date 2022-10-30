defmodule StartServer do
  @moduledoc false

  # convenience module so that this instruction exists as a compiled artifact
  # on all nodes of the cluster

  def on_port(port) do
    Task.start(fn ->
      Supervisor.start_link(
        [
          {Bandit, plug: MultiversesHttpTest.Router, scheme: :http, options: [port: port]}
        ],
        strategy: :one_for_one
      )

      receive do
        :hold -> :open
      end
    end)
  end
end
