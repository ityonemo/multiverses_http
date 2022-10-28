defmodule Multiverses.Http.Application do
  @moduledoc false

  use Application

  alias Multiverses.Http

  def start(_type, _args) do
    Supervisor.start_link([Http], strategy: :one_for_one, name: __MODULE__)
  end
end
