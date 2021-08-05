defmodule Surgex.Parser.ResourceParser do
  @moduledoc false

  @spec call(term(), fun) :: {:ok, term() | nil} | {:error, Keyword.t() | atom()}
  def call(nil, _item_parser), do: {:ok, nil}

  def call(resource, item_parser) when is_map(resource) do
    resource
    |> item_parser.()
    |> close()
  end

  def call(_, _), do: {:error, :invalid_resource}

  defp close({:ok, result}), do: {:ok, result}
  defp close({:error, :invalid_pointers, pointers}), do: {:error, pointers}
end
