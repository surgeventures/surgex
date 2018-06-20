defmodule Surgex.Parser.ResourceParser do
  @moduledoc false

  def call(nil, _item_parser), do: {:ok, nil}

  def call(resource, item_parser) do
    resource
    |> item_parser.()
    |> close()
  end

  defp close({:ok, result}), do: {:ok, result}
  defp close({:error, :invalid_pointers, pointers}), do: {:error, pointers}
end
