defmodule Surgex.ParseusExtras.IdListParser do
  @moduledoc false

  alias Surgex.ParseusExtras.IdParser

  def call(input) when is_binary(input) do
    input
    |> String.split(",")
    |> parse_list()
  end

  defp parse_list(list) do
    case Enum.reduce(list, [], &parse_list_item/2) do
      :error -> :error
      ids -> {:ok, Enum.reverse(ids)}
    end
  end

  defp parse_list_item(_item, :error), do: :error
  defp parse_list_item(item, result) do
    case IdParser.call(item) do
      {:ok, id} -> [id | result]
      _ -> :error
    end
  end
end
