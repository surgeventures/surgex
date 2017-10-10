defmodule Surgex.RPC.HTTPAdapter do
  @moduledoc """
  Transports RPC calls through HTTP requests protected by secret header.

  > **DEPRECATED:** The HTTP adapter doesn't support the push flow and it doesn't have a server
  > component, which means it can only play a role of a call flow client for the RPC server
  > implemented in other languages.
  >
  > While both of these could be implemented (with push client implemented via spawn and without
  > caring about spawned process failures or server temporary downtime and the server component
  > implemented either as Plug module or stand-alone cowboy server), all of these functionalities
  > are a better fit for the `Surgex.RPC.AMQPAdapter` and hence that's the recommended transport
  > method in such cases.

  ## Usage

  In order to use this adapter in your client, use the following code:

      defmodule MyProject.RemoteRPC do
        use Surgex.RPC.Client

        transport :http,
          url: "https://app.example.com/rpc",
          secret: "remote-rpc-secret"

        # ...
      end

  You can also configure the adapter per environment in your Mix config as follows:

      config :my_project, MyProject.RemoteRPC,
        transport: [adapter: :http,
                    url: {:system, "REMOTE_RPC_URL"},
                    secret: {:system, "REMOTE_RPC_SECRET"}]

  """

  alias Surgex.RPC.{TransportError, Utils}

  @doc false
  def call(request_payload, opts) do
    url = Utils.get_config!(opts, :url)
    secret = Utils.get_config!(opts, :secret)

    headers = build_headers(secret)
    response_body = make_http_request(url, request_payload, headers)

    response_body
  end

  defp build_headers(secret) do
    [
      {"X-RPC-Secret", secret}
    ]
  end

  defp make_http_request(url, body, headers) do
    response = HTTPoison.post!(url, body, headers)
    if response.status_code != 200 do
      raise TransportError, adapter: __MODULE__, context: response.status_code
    end

    response.body
  end
end
