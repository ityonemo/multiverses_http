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

    # request: core function

    def request(request = %Req.Request{}) do
      request(request, [])
    end

    def request(request), do: request |> new |> request

    def request(request, options) do
      new_header = [{"x-multiverse-id", "#{Http.registered_id()}"}]
      Req.request(request, Keyword.put(options, :headers, new_header))
    end

    def request!(request) do
      case request(request) do
        {:ok, response} -> response
        {:error, exception} -> raise exception
      end
    end

    def request!(request, options) do
      case request(request, options) do
        {:ok, response} -> response
        {:error, exception} -> raise exception
      end
    end
  end
end
