import Config

config :multiverses_http, http_clients: [Req]

if config_env() != :prod do
  config :multiverses, with_replicant: true
end
