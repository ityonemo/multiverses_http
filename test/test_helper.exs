Task.start_link(fn ->
  System.cmd("epmd", [])
end)

Process.sleep(100)
{:ok, _} = :net_kernel.start([:primary, :shortnames])
:peer.start(%{name: :peer})
:global.sync()
[peer] = Node.list()
:rpc.call(peer, :code, :add_paths, [:code.get_path()])
:rpc.call(peer, Application, :ensure_all_started, [:mix])
:rpc.call(peer, Application, :ensure_all_started, [:logger])
:rpc.call(peer, Logger, :configure, [[level: Logger.level()]])
:rpc.call(peer, Mix, :env, [Mix.env()])
:rpc.call(peer, Application, :ensure_all_started, [:telemetry])
:rpc.call(peer, Application, :ensure_all_started, [:multiverses])
:rpc.call(peer, Application, :ensure_all_started, [:multiverses_http])

:rpc.call(peer, Server, :start, [6002])

Server.start(6001)

ExUnit.start()
