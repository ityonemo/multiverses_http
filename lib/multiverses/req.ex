require Multiverses.Http

if Req in Multiverses.Http._http_clients() do
  defmodule Multiverses.Req do
    @moduledoc """
    `Multiverses` shim for the `Req` library.  Implements all functions found in the
    `Req` module, replacing `request`, `delete`, `get`, `head`, `patch`, `post`, and
    `put` (and related functions) with their `Multiverses` equivalent.

    Must be used in tandem with `Multiverses.Plug`
    """

    use Multiverses.Clone,
      module: Req,
      except: [
        delete!: 1,
        delete: 1,
        delete!: 2,
        delete: 2,
        get!: 1,
        get: 1,
        get!: 2,
        get: 2,
        head!: 1,
        head: 1,
        head!: 2,
        head: 2,
        patch!: 1,
        patch: 1,
        patch!: 2,
        patch: 2,
        post!: 1,
        post: 1,
        post!: 2,
        post: 2,
        put!: 1,
        put: 1,
        put!: 2,
        put: 2,
        request!: 1,
        request!: 2,
        request: 1,
        request: 2,
        # deprecated
        put!: 3,
        post!: 3,
        build: 2,
        build: 3
      ]

    alias Multiverses.Http

    operations = [:get, :delete, :head, :patch, :put, :post]

    for function <- operations do
      bang = :"#{function}!"

      @doc """
      see `Req.#{bang}/2`
      """
      def unquote(bang)(url_or_request, options \\ []) do
        case unquote(function)(url_or_request, options) do
          {:ok, response} -> response
          {:error, exception} -> raise exception
        end
      end

      @doc """
      see `Req.#{function}/2`
      """
      def unquote(function)(url_or_request, options \\ [])

      def unquote(function)(request = %Req.Request{}, options) do
        request(%{request | method: unquote(function)}, options)
      end

      def unquote(function)(url, options) do
        request([method: unquote(function), url: URI.parse(url)] ++ options)
      end
    end

    # request: core function

    def request(request = %Req.Request{}) do
      request(request, [])
    end

    def request(request), do: request |> new |> request

    def request(request, options) do
      old_header = Keyword.get(options, :headers, [])
      new_header = [{"x-multiverse-id", "#{Http.registered_id()}"} | old_header]
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
