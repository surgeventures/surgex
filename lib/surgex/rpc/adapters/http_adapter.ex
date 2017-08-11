defmodule Surgex.RPC.HTTPAdapter do
  @moduledoc """
  Transports RPC calls through HTTP requests protected with a secret header.

  ## Usage

  In order to use this adapter in you client, use the following code:

      defmodule ShedulAPI.CoreRPC do
        use Surgex.RPC.Client

        transport :http,
          url: "https://app.example.com/rpc",
          secret: "my-rpc-secret"

        # ...
      end

  """

  alias Surgex.RPC.TransportError

  @doc false
  def call({service_name, request_buf}, opts) do
    url = Keyword.fetch!(opts, :url)
    secret = Keyword.fetch!(opts, :secret)

    headers = build_headers(secret)
    request_body = build_request_body(service_name, request_buf)
    response_body = make_http_request(url, headers, request_body)

    response_body
    |> decode_response_body()
    |> handle_response()
  end

  defp build_headers(secret) do
    [
      {"X-RPC-Secret", secret}
    ]
  end

  defp build_request_body(service_name, request_buf) do
    Poison.encode!(%{
      "service_name" => service_name,
      "request_buf_b64" => Base.encode64(request_buf)
    })
  end

  defp make_http_request(url, headers, body) do
    response = HTTPoison.post!(url, body, headers)
    if response.status_code != 200 do
      raise TransportError, adapter: __MODULE__, context: response.status_code
    end

    response.body
  end

  defp decode_response_body(body) do
    Poison.decode!(body)
  end

  defp handle_response(%{"response_buf_b64" => buf_b64}) when is_binary(buf_b64) do
    {:ok, Base.decode64!(buf_b64)}
  end
  defp handle_response(%{"errors" => errors}) when is_list(errors) do
    errors = Enum.map(errors, fn error ->
      {
        decode_error_reason(error["reason"]),
        decode_error_pointer(error["pointer"])
      }
    end)

    {:error, errors}
  end

  defp decode_error_reason(":" <> reason) do
    String.to_existing_atom(reason)
  rescue
    _ -> reason
  end
  defp decode_error_reason(reason), do: reason

  defp decode_error_pointer(nil), do: nil
  defp decode_error_pointer(access_path) do
    Enum.map(access_path, fn [access_type, access_key] ->
      access_type_atom = case access_type do
        "struct" -> :struct
        "repeated" -> :repeated
        "map" -> :map
      end

      {access_type_atom, access_key}
    end)
  end
end
