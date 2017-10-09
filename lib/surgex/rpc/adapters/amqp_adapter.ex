defmodule Surgex.RPC.AMQPAdapter do
  @moduledoc """
  Transports RPC calls through AMQP messaging queue.

  ## Usage

  In order to use this adapter in your client, use the following code:

      defmodule MyProject.MyRPC do
        use Surgex.RPC.Client

        transport :amqp,
          url: "amqp://example.com",
          queue: "my_rpc",
          timeout: 15_000

        # ...
      end

  You can also configure the adapter per environment in your Mix config as follows:

      config :my_project, MyProject.MyRPC,
        transport: [adapter: :amqp,
                    url: {:system, "MY_RPC_AMQP_URL"}]

  """

  alias AMQP.{Basic, Channel, Connection, Queue}
  alias Surgex.RPC.{Config, TransportError}

  @doc false
  def call(request_payload, opts) do
    url = Config.get!(opts, :url)
    queue = Config.get!(opts, :queue)
    timeout = Config.get(opts, :timeout, 15_000)

    make_amqp_request(request_payload, url, queue, timeout)
  end

  defp make_amqp_request(request, url, queue, timeout) do
    {:ok, connection} = Connection.open(url)
    {:ok, channel} = Channel.open(connection)

    {:ok, %{queue: response_queue}} = Queue.declare(channel, "", exclusive: true)
    Basic.consume(channel, response_queue, nil, no_ack: true)

    correlation_id = generate_request_id()
    opts = put_expiration([
      reply_to: response_queue,
      correlation_id: correlation_id], timeout)

    Basic.publish(channel, "", queue, request, opts)

    wait_for_response(correlation_id, timeout)
  end

  defp generate_request_id do
    24
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  defp put_expiration(opts, nil), do: opts
  defp put_expiration(opts, timeout), do: Keyword.put(opts, :expiration, to_string(timeout))

  defp wait_for_response(correlation_id, timeout) do
    receive do
      {:basic_deliver, "service_error", %{correlation_id: ^correlation_id}} ->
        raise TransportError, adapter: __MODULE__, context: :service_error
      {:basic_deliver, payload, %{correlation_id: ^correlation_id}} ->
        payload
    after
      timeout || :infinity ->
        raise TransportError, adapter: __MODULE__, context: {:timeout, timeout}
    end
  end
end
