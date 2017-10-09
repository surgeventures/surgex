defmodule Surgex.RPC.RequestPayload do
  @moduledoc false

  def encode(service_name, request_buf) do
    Poison.encode!(%{
      "service_name" => service_name,
      "request_buf_b64" => Base.encode64(request_buf),
    })
  end

  def decode(payload) do
    %{
      "service_name" => service_name,
      "request_buf_b64" => request_buf_b64,
    } = Poison.decode!(payload)
    request_buf = Base.decode64!(request_buf_b64)

    {service_name, request_buf}
  end
end
