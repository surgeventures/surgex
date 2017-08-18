defmodule Surgex.RPC.ResponsePayload do
  @moduledoc false

  def decode(payload) do
    case Poison.decode!(payload) do
      %{"errors" => errors} ->
        {:error, decode_errors(errors)}
      %{"response_buf_b64" => response_buf_b64} ->
        {:ok, Base.decode64!(response_buf_b64)}
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

  defp decode_error_reason(%{"reason" => ":" <> reason}), do: String.to_atom(reason)
  defp decode_error_reason(%{"reason" => reason}), do: reason

  defp decode_error_pointer(%{"pointer" => pointer}) do
    Enum.map(pointer, &decode_error_pointer_item/1)
  end
  defp decode_error_pointer(_), do: nil

  defp decode_error_pointer_item(["struct", key]), do: {:struct, key}
  defp decode_error_pointer_item(["map", key]), do: {:map, key}
  defp decode_error_pointer_item(["repeated", key]), do: {:repeated, key}
end
