defmodule Surgex.RPC.HTTPAdapter do
  @moduledoc """
  Transports RPC calls through HTTP requests protected with a secret header.

  ## Usage

  In order to use this adapter in your client, use the following code:

      defmodule MyProject.MyRPC do
        use Surgex.RPC.Client

        transport :http,
          url: "https://app.example.com/rpc",
          secret: "my-rpc-secret"

        # ...
      end

  You can also configure the adapter per environment in your Mix config as follows:

      config :my_project, MyProject.MyRPC,
        transport: [adapter: :http,
                    url: {:system, "MY_RPC_URL"},
                    secret: {:system, "MY_RPC_SECRET"}]

  """

  alias Surgex.RPC.{Config, TransportError}

  @doc false
  def call(request_payload, opts) do
    url = Config.get!(opts, :url)
    secret = Config.get!(opts, :secret)

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
