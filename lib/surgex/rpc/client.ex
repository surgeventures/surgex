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

  alias Surgex.Config
  alias Surgex.RPC.{
    CallError,
    HTTPAdapter,
    Payload,
    Processor,
    TransportError,
  }

  defmacro __using__(opts) do
    proto_root = Keyword.get(opts, :proto_root, "./proto")

    quote do
      import Surgex.RPC.Client, only: [transport: 1, transport: 2, proto: 1, service: 1]

      def call(request_struct) do
        do_call(request_struct, :call)
      end

      def call!(request_struct) do
        do_call(request_struct, :call!)
      end

      def __proto_root__ do
        unquote(proto_root)
      end

      def __transport_opts__ do
        dsl_opts = try do
          apply(__MODULE__, :__transport_opts_dsl__, [])
        rescue
          UndefinedFunctionError -> []
        end

        config_opts = Config.get(__MODULE__, :transport) || []

        Keyword.merge(config_opts, dsl_opts)
      end

      defp do_call(request_struct = %{__struct__: request_mod}, method) do
        transport_opts = __transport_opts__()
        service_mod = __service_mod__(request_mod)
        service_opts = service_mod.__service_opts__()

        apply(Surgex.RPC.Client, method, [request_struct, service_opts, transport_opts])
      end
    end
  end

  @doc """
  Specifies a transport adapter for the RPC calls along with its options.

  The following adapters are supported:

  - `Surgex.RPC.HTTPAdapter`

  You may also use your own adapter module by passing it as first argument.
    """
  defmacro transport(adapter, adapter_opts \\ []) do
    opts = Keyword.put(adapter_opts, :adapter, adapter)

    quote do
      def __transport_opts_dsl__, do: unquote(opts)
    end
  end

  @doc """
  Attaches a service inferring its options from given proto name.

  Supports either atom or binary name. Check out moduledoc for `Surgex.RPC.Client` for more info.
  """
  defmacro proto(name) do
    {proto, service_name} = case name do
      atom when is_atom(atom) ->
        {
          [from: Path.expand("../proto/#{name}.proto", __CALLER__.file)],
          to_string(name)
        }
      string when is_binary(string) ->
        {
          [from: string],
          string
          |> Path.basename
          |> Path.rootname
        }
    end

    quote do
      service(
        proto: unquote(proto),
        service_name: unquote(service_name),
      )
    end
  end

  @doc """
  Attaches a service to the client module with a customized config.

  ## Options

  - `proto`: options passed to `Protobuf`, usually `[from: "some/proto/file.proto"]`
  - `service_name`: string identifier of the service; defaults to proto file's root name
  - `service_mod`: base module that hosts the proto structures; defaults to camelized service name
    nested in the client module
  - `request_mod`: request struct module; defaults to `Request` structure nested in the service
    module
  - `response_mod`: response struct module; defaults to `Response` structure nested in the service
    module
  - `mock_mod`: mock module; defaults to service module suffixed with `Mock`

  """
  # credo:disable-for-next-line /ABCSize|CyclomaticComplexity/
  defmacro service(opts) do
    proto =
      opts
      |> Keyword.fetch!(:proto)
      |> Code.eval_quoted([], __CALLER__)
      |> elem(0)

    service_name = Keyword.fetch!(opts, :service_name)

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

        use Protobuf, unquote(proto)

        def __service_opts__, do: unquote(service_opts)
      end
    end
  end

  @doc """
  Makes a remote call with specific request struct, service opts and transport opts.

  This is a base client function that all remote calls end up going through. It can be used to make
  an RPC call without the custom client module. Client modules that `use Surgex.RPC.Client` fill all
  arguments except the request struct and offer a `call/1` equivalent of this function.
  """
  def call(request_struct, service_opts, transport_opts) do
    service_name = Keyword.fetch!(service_opts, :service_name)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    mock_mod = Keyword.fetch!(service_opts, :mock_mod)

    request_buf = request_mod.encode(request_struct)

    result =
      call_mock(request_buf, request_mod, response_mod, mock_mod) ||
      call_adapter(service_name, request_buf, transport_opts)

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

  defp call_mock(request_buf, request_mod, response_mod, mock_mod) do
    if Application.get_env(:surgex, :rpc_mocking_enabled) do
      Processor.call(mock_mod, request_buf, request_mod, response_mod)
    end
  rescue
    error -> raise TransportError, adapter: :mock, context: error
  end

  defp call_adapter(service_name, request_buf, opts) do
    {adapter, adapter_opts} = Keyword.pop(opts, :adapter)
    request_payload_buf = Payload.encode(service_name, request_buf)
    response_payload_buf = case adapter do
      :http ->
        HTTPAdapter.call(request_payload_buf, adapter_opts)
      adapter_mod ->
        adapter_mod.call(request_payload_buf, adapter_opts)
    end

    Payload.decode(response_payload_buf)
  end

  defp handle_non_failing_response({:ok, response}), do: response
  defp handle_non_failing_response({:error, errors}) do
    raise CallError, errors: errors
  end
end
