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

  require Logger
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

        Surgex.RPC.Server.process(request_buf, service_opts)
      end

      defmodule unquote(worker_mod) do
        @moduledoc false

        use AMQP
        use GenServer
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
          spawn fn -> consume(chan, meta, payload) end
          {:noreply, chan}
        end
        def handle_info({:DOWN, _, :process, _pid, _reason}, _) do
          {:ok, chan} = connect()
          {:noreply, chan}
        end

        defp connect do
          url = Config.get!(__transport_opts__(), :url)
          queue = Config.get!(__transport_opts__(), :queue)

          case init_conn_chan_queue(url, queue) do
            {:ok, conn, chan} ->
              Process.monitor(conn.pid)
              Logger.debug(fn -> "Connected to #{url}, serving RPC calls from #{queue}" end)
              {:ok, _consumer_tag} = Basic.consume(chan, queue)
              {:ok, chan}
            :error ->
              Logger.error(fn -> "Connection to #{url} failed, reconnecting in 5s" end)
              :timer.sleep(5_000)
              connect()
          end
        end

        defp init_conn_chan_queue(url, queue) do
          case Connection.open(url) do
            {:ok, conn} ->
              {:ok, chan} = Channel.open(conn)
              Basic.qos(chan, prefetch_count: 1)
              Queue.declare(chan, queue)
              {:ok, conn, chan}
            {:error, _} ->
              :error
          end
        end

        defp consume(chan, meta, payload) do
          {response, error} = try_process(payload)
          respond(response, chan, meta)
          Basic.ack(chan, meta.delivery_tag)

          if error do
            {exception, stacktrace} = error
            reraise(exception, stacktrace)
          end
        end

        defp try_process(payload) do
          response = __server_mod__().process(payload)
          {response, nil}
        rescue
          exception ->
            stacktrace = System.stacktrace
            {"ESRV", {exception, stacktrace}}
        end

        defp respond(nil, _chan, _meta), do: nil
        defp respond(response, chan, meta) do
          %{
            correlation_id: correlation_id,
            reply_to: reply_to
          } = meta

          Basic.publish(chan, "", reply_to, response, correlation_id: correlation_id)
        end
      end
    end
  end

  def process(request_buf, service_opts) do
    service_name = Keyword.fetch!(service_opts, :service_name)
    service_mod = Keyword.fetch!(service_opts, :service_mod)
    request_mod = Keyword.fetch!(service_opts, :request_mod)
    response_mod = Keyword.fetch!(service_opts, :response_mod)
    request_type = detect_request_type(response_mod)

    case request_type do
      :call ->
        response = log_process(request_type, service_name, fn ->
          Processor.call(service_mod, request_buf, request_mod, response_mod)
        end)
        ResponsePayload.encode(response)
      :push ->
        log_process(:push, service_name, fn ->
          Processor.call(service_mod, request_buf, request_mod)
        end)
        nil
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
end
