defmodule Server do
  def start(port) do
    Task.start(fn ->
      Bandit.start_link(plug: MultiversesHttpTest.Router, port: port)

      receive do
        :block -> :forever
      end
    end)
  end
end
