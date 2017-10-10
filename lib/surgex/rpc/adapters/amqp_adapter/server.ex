defmodule Surgex.RPC.AMQPAdapter.Server do
  @moduledoc false

  use AMQP
  use GenServer
  require Logger
  alias AMQP.{Basic, Channel, Connection, Queue}
  alias Surgex.RPC.Config

  def __server_mod__ do
    nil
  end

  def __transport_opts__ do
    []
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
