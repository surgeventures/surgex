defmodule Surgex.Parser.SortParser do
  @moduledoc """
  Parses the JSON API's sort parameter according to the
  [JSON API spec](http://jsonapi.org/format/#fetching-sorting).

  Produces a `{direction, column}` tuple, in which `direction` is either `:asc` or `:desc` and
  `column` is a safely atomized and underscored column name.
  """

  @doc false
  @spec call(nil, any) :: {:ok, nil}
  @spec call(String.t(), [atom]) :: {:ok, {:asc | :desc, atom}} | {:error, :invalid_sort_column}
  def call(nil, _allowed_columns), do: {:ok, nil}

  def call(input, allowed_columns) when is_binary(input) do
    case input do
      "-" <> column ->
        validate_allowed_columns(column, allowed_columns, :desc)

      column ->
        validate_allowed_columns(column, allowed_columns, :asc)
    end
  end

  defp validate_allowed_columns(column, allowed_columns, direction) do
    column_atom = atomize_maybe_dasherized(column)

    if column_atom && column_atom in allowed_columns do
      {:ok, {direction, column_atom}}
    else
      {:error, :invalid_sort_column}
    end
  end

  defp atomize_maybe_dasherized(string) do
    atomize(string) ||
      string
      |> String.replace("-", "_")
      |> atomize
  end

  defp atomize(string) do
    String.to_existing_atom(string)
  rescue
    ArgumentError -> nil
  end

  @doc """
  Flattens the result of the parser (sort tuple) into `*_by` and `*_direction` keys.

  ## Examples

      iex> SortParser.flatten({:ok, sort: {:asc, :col}}, :sort)
      {:ok, sort_by: :col, sort_direction: :asc}

  """
  @spec flatten({:ok, Keyword.t()}, atom) :: {:ok, {:asc | :desc, atom}}
  def flatten({:ok, opts}, key) do
    case Keyword.pop(opts, key) do
      {nil, _} ->
        {:ok, opts}

      {{direction, column}, rem_opts} ->
        final_opts = Keyword.merge(rem_opts, sort_by: column, sort_direction: direction)

        {:ok, final_opts}
    end
  end

  def flatten(input, _key), do: input
end
