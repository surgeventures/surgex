defmodule Surgex.Parser.IntegerParser do
  @moduledoc false

  @type errors :: :invalid_integer | :out_of_range

  @spec call(any, list) :: {:ok, integer | nil} | {:error, errors}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}

  def call(input, opts) when is_integer(input) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    validate_range(input, min, max)
  end

  def call(input, opts) when is_binary(input) do
    min = Keyword.get(opts, :min)
    max = Keyword.get(opts, :max)

    case Integer.parse(input) do
      {int, ""} ->
        validate_range(int, min, max)

      _ ->
        {:error, :invalid_integer}
    end
  end

  def call(_input, _opts), do: {:error, :invalid_integer}

  defp validate_range(input, min, max) do
    case input do
      int when (is_integer(min) and int < min) or (is_integer(max) and int > max) ->
        {:error, :out_of_range}

      int ->
        {:ok, int}
    end
  end
end
