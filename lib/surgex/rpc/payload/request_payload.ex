defmodule Surgex.RPC.RequestPayload do
  @moduledoc false

  def encode(service_name, request_buf) do
    Poison.encode!(%{
      "service_name" => service_name,
      "request_buf_b64" => Base.encode64(request_buf),
    })
  end
end
