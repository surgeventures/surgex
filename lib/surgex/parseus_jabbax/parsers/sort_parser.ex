defmodule Surgex.ParseusJabbax.SortParser do
  @moduledoc false

  def call(input, alowed_keys) when is_binary(input) and is_list(alowed_keys) do
    input
    |> String.split(",")
    |> parse_list(alowed_keys)
    |> unlist_single()
  end

  defp parse_list(list, alowed_keys) do
    case Enum.reduce(list, [], &parse_list_item(&1, &2, alowed_keys)) do
      :error -> :error
      result -> {:ok, result}
    end
  end

  defp parse_list_item(_input, :error, _alowed_keys), do: :error
  defp parse_list_item("-" <> input, result, alowed_keys) do
    if input in alowed_keys do
      [{make_key(input), :desc} | result]
    else
      :error
    end
  end
  defp parse_list_item(input, result, alowed_keys) do
    if input in alowed_keys do
      [{make_key(input), :asc} | result]
    else
      :error
    end
  end

  defp make_key(input) do
    unlist_single(
      input
      |> Macro.underscore()
      |> String.replace("-", "_")
      |> String.to_atom())
  end

  defp unlist_single([]), do: nil
  defp unlist_single([item]), do: item
  defp unlist_single(list), do: list
end
