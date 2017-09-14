defmodule Surgex.ParseusJabbax.IncludeParser do
  @moduledoc false

  def call(input, allowed_relationships) when is_binary(input) and is_list(allowed_relationships) do
    input
    |> String.split(",")
    |> parse_list(allowed_relationships)
  end

  defp parse_list(list, allowed_relationships) do
    case Enum.reduce(list, [], &parse_list_item(&1, &2, allowed_relationships)) do
      :error -> :error
      result -> {:ok, result}
    end
  end

  defp parse_list_item(_input, :error, _allowed_relationships), do: :error
  defp parse_list_item(input, result, allowed_relationships) do
    if input in allowed_relationships do
      [make_key_or_keys(input) | result]
    else
      :error
    end
  end

  defp make_key_or_keys(input) do
    unlist_single(
      input
      |> Macro.underscore()
      |> String.replace("-", "_")
      |> String.split("/")
      |> Enum.map(&String.to_atom/1))
  end

  defp unlist_single([item]), do: item
  defp unlist_single(list), do: list
end
