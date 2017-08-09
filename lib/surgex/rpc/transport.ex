defmodule Surgex.RPC.Transport do
  alias Surgex.Config

  def call(service_name, request_buf) do
    url = get_config(:rpc_url)
    secret = get_config(:rpc_secret)
    http_headers = build_headers(secret)
    http_request_body = build_request_body(service_name, request_buf)
    http_response = HTTPoison.post!(url, http_request_body, http_headers)
    if http_response.status_code != 200 do
      raise("transport failed with code #{http_response.status_code}")
    end

    http_response.body
    |> Poison.decode!()
    |> handle_response()
  end

  defp get_config(key) do
    :surgex
    |> Application.get_env(key)
    |> Config.parse()
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
