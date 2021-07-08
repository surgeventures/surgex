defmodule Surgex.Parser.FloatParser do
  @moduledoc false
  @type errors :: :invalid_float | :out_of_range

  @spec call(Surgex.Types.json_value(), list) :: {:ok, float | nil} | {:error, errors}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}

  def call(input, opts) when is_integer(input) do
    call(input / 1, opts)
  end

  def call(input, opts) when is_float(input) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    validate_range(input, min, max)
  end

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

  def call(_input, _opts), do: {:error, :invalid_float}

  defp validate_range(input, min, max) do
    case input do
      float when (is_number(min) and float < min) or (is_number(max) and float > max) ->
        {:error, :out_of_range}

      float ->
        {:ok, float}
    end
  end
end
