import Config

if config_env() != :prod do
  config :multiverses, with_replicant: true
end
