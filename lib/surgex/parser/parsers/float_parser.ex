defmodule Surgex.Parser.FloatParser do
  @moduledoc false

  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call(input, opts) when is_binary(input) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    case Float.parse(input) do
      {float, ""} ->
        validate_range(float, min, max)
      _ ->
        {:error, :invalid_float}
    end
  end

  defp validate_range(input, min, max) do
    case input do
      float when (is_number(min) and float < min) or (is_number(max) and float > max) ->
        {:error, :out_of_range}
      float ->
        {:ok, float}
    end
  end
end
