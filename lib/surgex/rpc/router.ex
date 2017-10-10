defmodule Surgex.RPC.Router do
  @moduledoc """
  Macros for defining a list of services later routed by RPC clients/servers.
  """

  alias Surgex.Config

  @doc false
  defmacro __using__(_) do
    quote do
      import Surgex.RPC.Router

      def __transport_opts__ do
        dsl_opts = try do
          apply(__MODULE__, :__transport_opts_dsl__, [])
        rescue
          UndefinedFunctionError -> []
        end

        config_opts = Config.get(__MODULE__, :transport) || []

        Keyword.merge(config_opts, dsl_opts)
      end

      def __service_opts__(request_mod_or_service_name)
      def __service_opts__(nil), do: nil
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

    proto_mod = case Keyword.fetch(opts, :proto_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{__CALLER__.module}.#{Macro.camelize(to_string(service_name))}"
    end

    service_mod = case Keyword.fetch(opts, :service_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{proto_mod}Service"
    end

    request_mod = case Keyword.fetch(opts, :request_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{proto_mod}.Request"
    end

    response_mod = case Keyword.fetch(opts, :response_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{proto_mod}.Response"
    end

    mock_mod = case Keyword.fetch(opts, :mock_mod) do
      {:ok, value} ->
        Macro.expand(value, __CALLER__)
      :error ->
        :"#{proto_mod}Mock"
    end

    service_opts = [
      service_name: service_name,
      proto_mod: proto_mod,
      service_mod: service_mod,
      request_mod: request_mod,
      response_mod: response_mod,
      mock_mod: mock_mod,
    ]

    quote do
      def __service_opts__(unquote(request_mod)), do: unquote(service_opts)
      def __service_opts__(unquote(service_name)), do: unquote(service_opts)

      defmodule unquote(proto_mod) do
        use Protobuf, unquote(proto)

        def __service_opts__, do: unquote(service_opts)
      end
    end
  end
end
