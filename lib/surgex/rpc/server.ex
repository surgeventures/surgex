defmodule Surgex.RPC.Server do
  @moduledoc """
  Responds to service calls from remote systems.

  ## Usage

  Here's how your RPC server module may look like:

      defmodule MyProject.MyRPC do
        use Surgex.RPC.Server

        # then, declare services with a convention driven config
        proto :create_user

        # ...or with custom proto file name (equivalent of previous call above)
        proto Path.expand("./proto/create_user.proto", __DIR__)

        # ...or with a completely custom config (equivalent of previous calls above)
        service proto: [from: Path.expand("./proto/create_user.proto", __DIR__)],
                service_name: "create_user",
                service_mod: __MODULE__.CreateUser,
                request_mod: __MODULE__.CreateUser.Request,
                response_mod: __MODULE__.CreateUser.Response
      end

  Having that, you can add your RPC to the supervision tree in `application.ex` as follows:

      defmodule MyProject.Application do
        use Application

        def start(_type, _args) do
          import Supervisor.Spec

          children = [
            supervisor(MyProject.Repo, []),
            supervisor(MyProject.Web.Endpoint, []),
            # ...
            supervisor(MyProject.MyRPC, []),
          ]

          opts = [strategy: :one_for_one, name: MyProject.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end

  """

  alias Surgex.RPC.{Processor, RequestPayload, ResponsePayload}

  defmacro __using__(_) do
    server_mod = __CALLER__.module
    worker_mod = :"#{__CALLER__.module}.Worker"

    quote do
      use Surgex.RPC.ServiceRoutingDSL
      use Supervisor
      require Logger

      def start_link(_opts \\ []) do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
      end

      def __worker_mod__ do
        unquote(worker_mod)
      end

      def init(_) do
        Supervisor.init([
          {__worker_mod__(), []}
        ], strategy: :one_for_one)
      end

      def process(request) do
        {service_name, request_buf} = RequestPayload.decode(request)
        service_opts = __service_opts__(service_name)

        service_mod = Keyword.fetch!(service_opts, :service_mod)
        request_mod = Keyword.fetch!(service_opts, :request_mod)
        response_mod = Keyword.fetch!(service_opts, :response_mod)
        request_type = detect_request_type(response_mod)

        case request_type do
          :call ->
            response = log_process(request_type, service_name, fn ->
              Processor.call(service_mod, request_buf, request_mod, response_mod)
            end)
            response_payload = ResponsePayload.encode(response)
            {:ok, response_payload}

          :push ->
            log_process(:push, service_name, fn ->
              Processor.call(service_mod, request_buf, request_mod)
            end)
            :ok
        end
      end

      defp detect_request_type(response_mod) do
        case Code.ensure_loaded(response_mod) do
          {:module, _} -> :call
          _ -> :push
        end
      end

      defp log_process(kind, service_name, process_func) do
        Logger.info(fn -> "Processing RPC #{kind}: #{service_name}" end)

        start_time = :os.system_time(:millisecond)
        result = process_func.()
        duration_ms = :os.system_time(:millisecond) - start_time
        status_text = case {kind, result} do
          {:push, _} -> "Processed"
          {:call, {:ok, _}} -> "Resolved"
          {:call, _} -> "Rejected"
        end

        Logger.info(fn -> "#{status_text} in #{duration_ms}ms" end)

        result
      end

      defmodule unquote(worker_mod) do
        @moduledoc false

        use GenServer
        use AMQP
        require Logger
        alias AMQP.{Basic, Channel, Connection, Queue}
        alias Surgex.RPC.Config

        def __server_mod__ do
          unquote(server_mod)
        end

        def __transport_opts__ do
          __server_mod__().__transport_opts__()
        end

        def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, [], [])

        def init(_opts), do: connect()

        def handle_info({:basic_consume_ok, _meta}, chan), do: {:noreply, chan}
        def handle_info({:basic_cancel, _meta}, chan), do: {:stop, :normal, chan}
        def handle_info({:basic_cancel_ok, _meta}, chan), do: {:noreply, chan}
        def handle_info({:basic_deliver, payload, meta}, chan) do
          spawn fn ->
            consume(chan, meta, payload)
          end

          {:noreply, chan}
        end
        def handle_info({:DOWN, _, :process, _pid, _reason}, _) do
          {:ok, chan} = connect()
          {:noreply, chan}
        end

        defp connect do
          case init_conn_chan_queue() do
            {:ok, conn, chan, queue} ->
              Process.monitor(conn.pid)
              {:ok, _consumer_tag} = Basic.consume(chan, queue)
              Logger.debug(fn ->
                url = Config.get!(__transport_opts__(), :url)
                "Connected to #{url}, serving RPC calls from #{queue}"
              end)

              {:ok, chan}
            :error ->
              Logger.error(fn ->
                url = Config.get!(__transport_opts__(), :url)
                "Connection to #{url} failed, reconnecting in 5s"
              end)

              :timer.sleep(5_000)
              connect()
          end
        end

        defp init_conn_chan_queue do
          url = Config.get!(__transport_opts__(), :url)
          queue = Config.get!(__transport_opts__(), :queue)

          case Connection.open(url) do
            {:ok, conn} ->
              {:ok, chan} = Channel.open(conn)
              Queue.declare(chan, queue)
              {:ok, conn, chan, queue}
            {:error, _} ->
              :error
          end
        end

        defp consume(chan, meta, payload) do
          {process_result, error, stacktrace} = try do
            {__server_mod__().process(payload), nil, nil}
          rescue
            error ->
              stacktrace = System.stacktrace
              {{:ok, "ESRV"}, error, stacktrace}
          end

          case process_result do
            :ok ->
              nil
            {:ok, response} ->
              %{
                correlation_id: correlation_id,
                reply_to: reply_to
              } = meta

              Basic.publish(chan, "", reply_to, response, correlation_id: correlation_id)
          end

          %{delivery_tag: tag} = meta
          Basic.ack(chan, tag)

          if error, do: reraise(error, stacktrace)
        end
      end
    end
  end
end
