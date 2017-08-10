defmodule Surgex.RPC.Client do
  alias Surgex.RPC.Transport

  defmacro __using__(_opts) do
    quote do
      import Surgex.RPC.Client, only: [transport: 1, transport: 2, proto: 1, service: 1]

      def call(request) do
        Surgex.RPC.Client.call(request, __transport__())
      end

      def call!(request) do
        Surgex.RPC.Client.call!(request, __transport__())
      end
    end
  end

  defmacro transport(adapter, adapter_opts) do
    opts = Keyword.put(adapter_opts, :adapter, adapter)

    quote do
      transport(unquote(opts))
    end
  end
  defmacro transport(opts) do
    quote do
      def __transport__ do
        unquote(opts)
      end
    end
  end

  defmacro proto(name) do
    quote do
      service(proto: unquote(name))
    end
  end

  defmacro service(opts) do
    proto = Keyword.fetch!(opts, :proto) |> Code.eval_quoted([], __CALLER__) |> elem(0)

    name = Keyword.get_lazy(opts, :name, fn ->
      proto
      |> Path.basename
      |> Path.rootname
    end)

    base_mod = case Keyword.fetch(opts, :namespace) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{__CALLER__.module}.#{Macro.camelize(to_string(name))}"
    end

    request_mod = :"#{base_mod}.Request"
    response_mod = :"#{base_mod}.Response"
    service_opts = [
      name: name,
      request: request_mod,
      response: response_mod
    ]

    quote do
      client_mod = __MODULE__

      defmodule unquote(base_mod) do
        @client_mod client_mod

        use Protobuf, from: unquote(proto)

        def __service_name__ do
          unquote(name)
        end

        def __transport__ do
          apply(@client_mod, :__transport__, [])
        end

        def call(request \\ []) do
          Surgex.RPC.Client.call(request, unquote(service_opts), __transport__())
        end

        def call!(request \\ []) do
          Surgex.RPC.Client.call!(request, unquote(service_opts), __transport__())
        end
      end
    end
  end

  def call(request_struct, transport_opts) do
    service_opts = infer_service_opts(request_struct)

    call(request_struct, service_opts, transport_opts)
  end
  def call(request, service_opts, transport_opts) when is_list(request) do
    request_mod = Keyword.fetch!(service_opts, :request)
    request_struct = apply(request_mod, :new, [request])

    call(request_struct, service_opts, transport_opts)
  end
  def call(request, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :name)
    request_mod = Keyword.fetch!(service_opts, :request)
    response_mod = Keyword.fetch!(service_opts, :response)
    request_buf = request_mod.encode(request)
    request = {service_name, request_buf}

    case Transport.call(request, transport_opts) do
      {:ok, response_buf} ->
        response = response_mod.decode(response_buf)
        {:ok, response}

      {:error, errors} ->
        {:error, errors}
    end
  end

  def call!(request_struct, transport_opts) do
    request_struct
    |> call(transport_opts)
    |> handle_non_failing_response()
  end
  def call!(request, service_opts, transport_opts) do
    request
    |> call(service_opts, transport_opts)
    |> handle_non_failing_response()
  end

  defp handle_non_failing_response({:ok, response}), do: response
  defp handle_non_failing_response({:error, errors}) do
    raise("Remote call rejected: #{inspect errors}")
  end

  defp infer_service_opts(_request_struct = %{__struct__: struct}) do
    request_mod = struct
    request_mod_parts = Module.split(request_mod)
    [_ | base_reverse_parts] = Enum.reverse(request_mod_parts)
    base_parts = Enum.reverse(base_reverse_parts)
    base_mod = :"Elixir.#{Enum.join(base_parts, ".")}"
    service_name = apply(base_mod, :__service_name__, [])
    response_mod = :"#{base_mod}.Response"

    [
      name: service_name,
      request: request_mod,
      response: response_mod
    ]
  end
end
