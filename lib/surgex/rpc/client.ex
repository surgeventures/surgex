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

      def call(request_struct) do
        do_call(request_struct, :call)
      end

      def call!(request_struct) do
        do_call(request_struct, :call!)
      end

      defp do_call(request_struct = %{__struct__: request_mod}, method) do
        transport_opts = __transport_opts__()
        service_mod = __service_mod__(request_mod)
        service_opts = service_mod.__service_opts__()

        apply(Surgex.RPC.Client, method, [request_struct, service_opts, transport_opts])
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

    mock_mod = case Keyword.fetch(opts, :mock_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{service_mod}Mock"
    end

    service_opts = [
      service_name: service_name,
      request_mod: request_mod,
      response_mod: response_mod,
      mock_mod: mock_mod,
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
    mock_mod = Keyword.fetch!(service_opts, :mock_mod)

    request_buf = request_mod.encode(request_struct)
    request_tuple = {service_name, request_buf}

    result =
      call_mock(request_buf, request_mod, response_mod, mock_mod) ||
      call_transport(request_tuple, transport_opts)

    case result do
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

  defp call_mock(request_buf, request_mod, response_mod, mock_mod) do
    if Application.get_env(:surgex, :rpc_mocking_enabled) do
      result =
        request_buf
        |> request_mod.decode()
        |> mock_mod.call()

      case result do
        :ok ->
          {:ok, response_mod.encode(response_mod.new())}
        {:ok, response_struct} ->
          {:ok, response_mod.encode(response_struct)}
        :error ->
          {:error, [error: nil]}
        {:error, errors} when is_list(errors) ->
          {:error, Enum.map(errors, &normalize_error/1)}
        {:error, error} ->
          {:error, normalize_error(error)}
      end
    end
  end

  defp normalize_error(reason) when is_atom(reason) or is_binary(reason), do: {reason, nil}
  defp normalize_error({reason, pointer}), do: {reason, pointer}

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
