defmodule Surgex.RPC.Client do
  @moduledoc """
  Calls services in remote systems.

  ## Usage

  Here's how your RPC client module may look like:

      defmodule MyProject.RemoteRPC do
        use Surgex.RPC.Client

        # then, declare services with a convention driven config
        proto :create_user

        # ...or with custom proto file name (equivalent of previous call above)
        proto Path.expand("./proto/create_user.proto", __DIR__)

        # ...or with a completely custom config (equivalent of previous calls above)
        service proto: [from: Path.expand("./proto/create_user.proto", __DIR__)],
                service_name: "create_user",
                service_mod: __MODULE__.CreateUser,
                request_mod: __MODULE__.CreateUser.Request,
                response_mod: __MODULE__.CreateUser.Response,
                mock_mod: __MODULE__.CreateUserMock
      end

  Having that, you can call your RPC as follows:

      alias MyProject.RemoteRPC
      alias MyProject.RemoteRPC.CreateUser.{Request, Response}

      request = %Request{}

      case RemoteRPC.call(request) do
        {:ok, response = %Response{}} ->
          # do stuff with response
        {:error, errors}
          # do stuff with errors
      end

      # ...or assume that a failure is out of the question
      response = RemoteRPC.call!(request)

  ## Testing

  You can enable client mocks by adding the following to your `config/test.exs`:

      config :surgex, rpc_mocking_enabled: true

  Then, you can add a mock module for your specific service to `test/support`. The module should be
  the `mock_mod` on sample above (which by default is a `service_mod` with the `Mock` suffix). For
  example, to mock the service sourced from `create_user.proto` on example above, you may implement
  the following module:

      # test/support/my_project/remote_rpc/create_user_mock.ex

      alias MyProject.RemoteRPC.CreateUser.{Request, Response}

      defmodule MyProject.RemoteRPC.CreateUserMock do
        # with default response
        def call(request = %Request{) do
          :ok
        end

        # ...or with specific response
        def call(request = %Request{}) do
          {:ok, %Response{}}
        end

        # ...or with default error
        def call(request = %Request{}) do
          :error
        end

        # ...or with specific error code
        def call(request = %Request{}) do
          {:error, :something_happened}
        end

        # ...or with specific error message
        def call(request = %Request{}) do
          {:error, "Something went wrong"}
        end

        # ...or with error related to specific part of the request
        def call(request = %Request{}) do
          {:error, {:specific_arg_error, struct: "user", struct: "images", repeated: 0}}
        end

        # ...or with multiple errors (all above syntaxes are supported)
        def call(request = %Request{}) do
          {:error, [
            :something_happened,
            "Something went wrong",
            {:specific_arg_error, struct: "user", struct: "images", repeated: 0}
          ]}
        end
      end

  You can define multiple `call` clauses in your mock and use pattern matching to create different
  output based on varying input.

  Mock bypasses the transport layer (obviously), but it still encodes/decodes your request protobuf
  just as regular client does and it still encodes/decodes the response from your mock. This ensures
  that your test structures are compilant with specific proto in use.

  """

  alias Surgex.RPC.{
    CallError,
    Processor,
    RequestPayload,
    ResponsePayload,
    Transport,
    TransportError,
  }

  defmacro __using__(_) do
    quote do
      use Surgex.RPC.Router

      def call(request_struct) do
        apply_client(request_struct, :call)
      end

      def call!(request_struct) do
        apply_client(request_struct, :call!)
      end

      def push(request_struct) do
        apply_client(request_struct, :push)
      end

      defp apply_client(request_struct = %{__struct__: request_mod}, method) do
        transport_opts = __transport_opts__()
        service_opts = __service_opts__(request_mod)

        apply(Surgex.RPC.Client, method, [request_struct, service_opts, transport_opts])
      end
    end
  end

  @doc """
  Makes a blocking remote call with specific request struct, service opts and transport opts.

  This is a base blocking client function that all remote calls end up going through. It can be used
  to make an RPC call without the custom client module. Client modules that `use Surgex.RPC.Client`
  fill all arguments except the request struct and offer a `call/1` equivalent of this function.
  """
  def call(request_struct, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :service_name)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    mock_mod = Keyword.fetch!(service_opts, :mock_mod)

    unless mod_defined?(response_mod), do: raise "Called to non-responding service"

    request_buf = request_mod.encode(request_struct)

    result =
      call_via_mock(request_buf, request_mod, response_mod, mock_mod)
      || call_via_adapter(service_name, request_buf, transport_opts)

    case result do
      {:ok, response_buf} ->
        {:ok, response_mod.decode(response_buf)}
      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Makes a non-failing remote call with specific request struct, service opts and transport opts.

  This is an equivalent of `call/3` that returns response instead of success tuple upon succes and
  that raises `Surgex.RPC.CallError` upon failure.
  """
  def call!(request_struct, service_opts, transport_opts) do
    request_struct
    |> call(service_opts, transport_opts)
    |> handle_non_failing_response()
  end

  defp call_via_mock(request_buf, request_mod, response_mod, mock_mod) do
    if Application.get_env(:surgex, :rpc_mocking_enabled) do
      Processor.call(mock_mod, request_buf, request_mod, response_mod)
    end
  rescue
    error -> raise TransportError, adapter: :mock, context: error
  end

  defp call_via_adapter(service_name, request_buf, opts) do
    {adapter, adapter_opts} = Keyword.pop(opts, :adapter)
    request_payload = RequestPayload.encode(service_name, request_buf)
    response_payload =
      adapter
      |> Transport.resolve()
      |> apply(:call, [request_payload, adapter_opts])

    ResponsePayload.decode(response_payload)
  end

  defp handle_non_failing_response({:ok, response}), do: response
  defp handle_non_failing_response({:error, errors}) do
    raise CallError, errors: errors
  end

  @doc """
  Makes a non-blocking remote push with specific request struct, service opts and transport opts.

  This is a base non-blocking client function that all remote pushes end up going through. It can be
  used to make an RPC push without the custom client module. Client modules that `use
  Surgex.RPC.Client` fill all arguments except the request struct and offer a `push/1` equivalent of
  this function.
  """
  def push(request_struct, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :service_name)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    mock_mod = Keyword.fetch!(service_opts, :mock_mod)

    if mod_defined?(response_mod), do: raise "Pushed to responding service"

    request_buf = request_mod.encode(request_struct)

    push_via_mock(request_buf, request_mod, mock_mod)
    || push_via_adapter(service_name, request_buf, transport_opts)

    :ok
  end

  defp push_via_mock(request_buf, request_mod, mock_mod) do
    if Application.get_env(:surgex, :rpc_mocking_enabled) && mod_defined?(mock_mod) do
      Processor.call(mock_mod, request_buf, request_mod)
    end
  rescue
    error -> raise TransportError, adapter: :mock, context: error
  end

  defp mod_defined?(mod) do
    case Code.ensure_loaded(mod) do
      {:module, _} -> true
      _ -> false
    end
  end

  defp push_via_adapter(service_name, request_buf, opts) do
    {adapter, adapter_opts} = Keyword.pop(opts, :adapter)
    request_payload = RequestPayload.encode(service_name, request_buf)

    adapter
    |> Transport.resolve()
    |> apply(:push, [request_payload, adapter_opts])
  end
end
