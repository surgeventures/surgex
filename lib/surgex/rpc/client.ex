defmodule Surgex.RPC.Client do
  @moduledoc """
  Calls services in remote systems.
  """

  alias Surgex.RPC.{
    CallError,
    HTTPAdapter,
  }

  defmacro __using__(_opts) do
    quote do
      import Surgex.RPC.Client, only: [transport: 1, transport: 2, proto: 1, service: 1]

      def call(request_struct = %{__struct__: request_mod}) do
        transport_opts = __transport_opts__()
        service_mod = __service_mod__(request_mod)
        service_opts = service_mod.__service_opts__()

        Surgex.RPC.Client.call(request_struct, service_opts, transport_opts)
      end

      def call!(request_struct = %{__struct__: request_mod}) do
        transport_opts = __transport_opts__()
        service_mod = __service_mod__(request_mod)
        service_opts = service_mod.__service_opts__()

        Surgex.RPC.Client.call!(request_struct, service_opts, transport_opts)
      end
    end
  end

  defmacro transport(adapter, adapter_opts \\ []) do
    opts = Keyword.put(adapter_opts, :adapter, adapter)

    quote do
      def __transport_opts__, do: unquote(opts)
    end
  end

  defmacro proto(proto) do
    quote do
      service(proto: unquote(proto))
    end
  end

  defmacro service(opts) do
    proto =
      opts
      |> Keyword.fetch!(:proto)
      |> Code.eval_quoted([], __CALLER__)
      |> elem(0)

    service_name = Keyword.get_lazy(opts, :service_name, fn ->
      proto
      |> Path.basename
      |> Path.rootname
    end)

    service_mod = case Keyword.fetch(opts, :service_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{__CALLER__.module}.#{Macro.camelize(to_string(service_name))}"
    end

    request_mod = case Keyword.fetch(opts, :request_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{service_mod}.Request"
    end

    response_mod = case Keyword.fetch(opts, :response_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{service_mod}.Response"
    end

    service_opts = [
      service_name: service_name,
      request_mod: request_mod,
      response_mod: response_mod
    ]

    quote do
      client_mod = __MODULE__

      def __service_mod__(unquote(request_mod)), do: unquote(service_mod)

      defmodule unquote(service_mod) do
        @client_mod client_mod

        use Protobuf, from: unquote(proto)

        def __service_opts__, do: unquote(service_opts)
      end
    end
  end

  def call(request_struct, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :service_name)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    request_buf = request_mod.encode(request_struct)
    request_tuple = {service_name, request_buf}

    case call_transport(request_tuple, transport_opts) do
      {:ok, response_buf} ->
        {:ok, response_mod.decode(response_buf)}
      {:error, errors} ->
        {:error, errors}
    end
  end

  def call!(request_struct, service_opts, transport_opts) do
    request_struct
    |> call(service_opts, transport_opts)
    |> handle_non_failing_response()
  end

  defp call_transport(request_tuple, opts) do
    {adapter, adapter_opts} = Keyword.pop(opts, :adapter)

    case adapter do
      :http ->
        HTTPAdapter.call(request_tuple, adapter_opts)
      adapter_mod ->
        adapter_mod.call(request_tuple, adapter_opts)
    end
  end

  defp handle_non_failing_response({:ok, response}), do: response
  defp handle_non_failing_response({:error, errors}) do
    raise CallError, errors: errors
  end
end
