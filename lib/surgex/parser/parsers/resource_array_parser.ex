defmodule Surgex.Parser.ResourceArrayParser do
  @moduledoc false

  def call(nil, _item_parser), do: {:ok, nil}
  def call(list, item_parser) when is_list(list) do
    list
    |> Enum.map(item_parser)
    |> Stream.with_index()
    |> Enum.reduce({[], []}, &reduce/2)
    |> close
  end

  defp reduce({{:ok, result}, _index}, {output, errors}) do
    {[result | output], errors}
  end
  defp reduce({{:error, :invalid_pointers, pointers}, index}, {output, errors}) do
    new_errors = Enum.map(pointers, fn {reason, pointer} ->
      {reason, "#{index}/#{pointer}"}
    end)

    {output, errors ++ new_errors}
  end

  defp close({output, []}), do: {:ok, Enum.reverse(output)}
  defp close({_output, errors}), do: {:error, errors}
end
