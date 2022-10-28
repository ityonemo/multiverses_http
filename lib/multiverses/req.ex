if Req in Application.fetch_env!(:multiverses_http, :http_clients) do
  defmodule Multiverses.Req do
    use Multiverses.Clone, module: Req, except: [
      delete!: 2,
      delete: 2,
      get!: 2,
      get: 2,
      head!: 2,
      head: 2,
      patch!: 2,
      patch: 2,
      post!: 2,
      post: 2,
      put!: 2,
      put: 2,
      request!: 1,
      request!: 2,
      request: 1,
      request: 2,
      # deprecated
      build: 2,
      build: 3
    ]

    alias Multiverses.Http

    def request(request = %Req.Request{}) do
      new_headers = [{"x-multiverse-id", "#{Http.registered_id()}"} | request.headers]
      Req.request(%{request | headers: new_headers})
    end
  end
end
