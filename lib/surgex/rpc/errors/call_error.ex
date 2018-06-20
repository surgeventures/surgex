defmodule Surgex.RPC.CallError do
  @moduledoc """
  Describes an unexpected RPC call rejection.
  """

  defexception [:errors]

  def message(%__MODULE__{errors: errors}) do
    errors
    |> Enum.map(&format_error/1)
    |> Enum.join(", ")
  end

  defp format_error({reason, nil}), do: format_error_reason(reason)

  defp format_error({reason, pointer}) do
    "#{format_error_reason(reason)} (at #{format_error_pointer(pointer)})"
  end

  defp format_error_reason(reason) when is_atom(reason), do: inspect(reason)
  defp format_error_reason(reason) when is_binary(reason), do: reason

  defp format_error_pointer(pointer) do
    accesses = Enum.map(pointer, &format_error_pointer_item/1)
    "[" <> Enum.join(accesses, ", ") <> "]"
  end

  defp format_error_pointer_item({:struct, value}), do: "Access.key!(:#{value})"
  defp format_error_pointer_item({:repeated, value}), do: "Access.at(#{value})"
  defp format_error_pointer_item({:map, value}), do: "Access.key!(#{inspect(value)})"
end
