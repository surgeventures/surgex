defmodule Surgex.Parser.ResourceArrayParser do
  @moduledoc false

  def call(list, item_parser, opts \\ [])
  def call(nil, _item_parser, _opts), do: {:ok, nil}
  def call(list, item_parser, opts) when is_list(list) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    case validate_length(list, min, max) do
      {:ok, list} -> parse_array(list, item_parser)
      {:error, :too_short} -> {:error, :too_short}
      {:error, :too_long} -> {:error, :too_long}
    end
  end

  defp validate_length(list, nil, nil), do: {:ok, list}
  defp validate_length(list, nil, max) do
    case length(list) > max do
      true -> {:error, :too_long}
      false -> {:ok, list}
    end
  end
  defp validate_length(list, min, nil) do
    case length(list) < min do
      true -> {:error, :too_short}
      false -> {:ok, list}
    end
  end
  defp validate_length(list, min, max) do
    case {length(list) < min, length(list) > max} do
      {true, _} -> {:error, :too_short}
      {false, true} -> {:error, :too_long}
      {false, false} -> {:ok, list}
    end
  end

  defp parse_array(list, item_parser) do
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
