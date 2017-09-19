defmodule Surgex.Parseus.ListParser do
  @moduledoc false

  alias Surgex.Parseus.CallUtil

  def call(input, opts \\ []) when is_binary(input) do
    input
    |> split(Keyword.get(opts, :delimiter, ","))
    |> parse_items(Keyword.get(opts, :item_parser, nil))
  end

  defp split(input, delimiter) do
    String.split(input, delimiter)
  end

  defp parse_items(list, nil), do: {:ok, list}
  defp parse_items(list, parser) do
    case Enum.reduce(list, [], &parse_item(&1, &2, parser)) do
      :error -> :error
      result -> {:ok, Enum.reverse(result)}
    end
  end

  defp parse_item(_, :error, _), do: :error
  defp parse_item(item, results, parser) do
    case CallUtil.call(parser, item) do
      {:ok, result} ->
        [result | results]
      _ ->
        :error
    end
  end
end
