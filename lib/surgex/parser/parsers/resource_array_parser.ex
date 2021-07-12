defmodule Surgex.Parser.ResourceArrayParser do
  @moduledoc false

  @type errors :: :too_short | :too_long | :invalid_array

  @spec call(term(), fun, Keyword.t()) :: {:ok, list | nil} | {:error, errors}
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

  def call(_input, _, _), do: {:error, :invalid_array}

  defp validate_length(list, min, max) do
    cond do
      min && length(list) < min ->
        {:error, :too_short}

      max && length(list) > max ->
        {:error, :too_long}

      true ->
        {:ok, list}
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
    new_errors =
      Enum.map(pointers, fn {reason, pointer} ->
        {reason, "#{index}/#{pointer}"}
      end)

    {output, errors ++ new_errors}
  end

  defp close({output, []}), do: {:ok, Enum.reverse(output)}
  defp close({_output, errors}), do: {:error, errors}
end
