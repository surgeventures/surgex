defmodule Surgex.RPC.Client do
  alias Surgex.RPC.{
    CallError,
    Transport,
  }

  defmacro __using__(_opts) do
    quote do
      import Surgex.RPC.Client, only: [transport: 1, transport: 2, proto: 1, service: 1]

      def call(request) do
        Surgex.RPC.Client.call(request)
      end

      def call!(request) do
        Surgex.RPC.Client.call!(request)
      end
    end
  end

  defmacro transport(adapter, adapter_opts \\ []) do
    opts = Keyword.put(adapter_opts, :adapter, adapter)

    quote do
      def __transport__, do: unquote(opts)
    end
  end

  defmacro proto(name) do
    quote do
      service(proto: unquote(name))
    end
  end

  defmacro service(opts) do
    proto =
      opts
      |> Keyword.fetch!(:proto)
      |> Code.eval_quoted([], __CALLER__)
      |> elem(0)

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

    request_mod = case Keyword.fetch(opts, :request) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{base_mod}.Request"
    end

    response_mod = case Keyword.fetch(opts, :request) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{base_mod}.Response"
    end

    service_opts = [
      name: name,
      request_mod: request_mod,
      response_mod: response_mod
    ]

    quote do
      client_mod = __MODULE__

      defmodule unquote(base_mod) do
        @client_mod client_mod

        use Protobuf, from: unquote(proto)

        def __service__, do: unquote(service_opts)

        def __transport__, do: @client_mod.__transport__()
      end
    end
  end

  def call(request_struct = %{__struct__: request_mod}) do
    base_mod = get_base_mod(request_mod)
    service_opts = base_mod.__service__()
    transport_opts = base_mod.__transport__()

    call(request_struct, service_opts, transport_opts)
  end
  def call(request_struct, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :name)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    request_buf = request_mod.encode(request_struct)
    request = {service_name, request_buf}

    case Transport.call(request, transport_opts) do
      {:ok, response_buf} ->
        response = response_mod.decode(response_buf)
        {:ok, response}

      {:error, errors} ->
        {:error, errors}
    end
  end

  def call!(request_struct) do
    request_struct
    |> call()
    |> handle_non_failing_response()
  end
  def call!(request_struct, service_opts, transport_opts) do
    request_struct
    |> call(service_opts, transport_opts)
    |> handle_non_failing_response()
  end

  defp handle_non_failing_response({:ok, response}), do: response
  defp handle_non_failing_response({:error, errors}) do
    raise CallError, errors: errors
  end

  defp get_base_mod(request_mod) do
    request_mod_parts = Module.split(request_mod)
    [_ | base_reverse_parts] = Enum.reverse(request_mod_parts)
    base_parts = Enum.reverse(base_reverse_parts)

    :"Elixir.#{Enum.join(base_parts, ".")}"
  end
end
