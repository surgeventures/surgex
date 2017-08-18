case Code.ensure_loaded(Protobuf) do
  {:module, _} ->
    defmodule Surgex.RPC.Payload.Proto do
      @moduledoc false

      use Protobuf, from: Path.expand("./proto/payload.proto", __DIR__)
    end

  _ ->
    defmodule Surgex.RPC.Payload.Proto.RequestPayload do
      @moduledoc false

      defstruct [:service_name, :request_buf]
    end

    defmodule Surgex.RPC.Payload.Proto.ResponsePayload do
      @moduledoc false

      defstruct [:response_buf, :errors]
    end
end

defmodule Surgex.RPC.Payload do
  @moduledoc false

  alias __MODULE__.Proto.{RequestPayload, ResponsePayload}

  def encode(service_name, request_buf) do
    RequestPayload.encode(%RequestPayload{
      service_name: service_name,
      request_buf: request_buf,
    })
  end

  def decode(response_payload_buf) do
    case ResponsePayload.decode(response_payload_buf) do
      %ResponsePayload{errors: errors} when length(errors) > 0 ->
        {:error, decode_errors(errors)}
      %ResponsePayload{response_buf: response_buf} ->
        {:ok, response_buf}
    end
  end

  defp decode_errors(errors) do
    Enum.map(errors, fn error ->
      {
        decode_error_reason(error),
        decode_error_pointer(error)
      }
    end)
  end

  defp decode_error_reason(%{reason_as_code: true, reason: reason}), do: String.to_atom(reason)
  defp decode_error_reason(%{reason: reason}), do: reason

  defp decode_error_pointer(%{pointer: []}), do: nil
  defp decode_error_pointer(%{pointer: pointer}) do
    Enum.map(pointer, &decode_error_pointer_item/1)
  end

  defp decode_error_pointer_item(%{type: "struct", key: key}), do: {:struct, key}
  defp decode_error_pointer_item(%{type: "map", key: key}), do: {:map, key}
  defp decode_error_pointer_item(%{type: "repeated", key: key}) do
    {:repeated, String.to_integer(key)}
  end
end
