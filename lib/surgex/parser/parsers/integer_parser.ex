defmodule Surgex.Parser.IntegerParser do
  @moduledoc false

  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call(input, opts) when is_binary(input) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    case Integer.parse(input) do
      {int, ""} when (is_integer(min) and int < min) or (is_integer(max) and int > max) ->
        {:error, :out_of_range}
      {int, ""} ->
        {:ok, int}
      _ ->
        {:error, :invalid_integer}
    end
  end
end
