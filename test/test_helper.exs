Supervisor.start_link([
  {Bandit, plug: MultiversesHttpTest.Router, scheme: :http, options: [port: 6001]}
], [strategy: :one_for_one])

ExUnit.start()
