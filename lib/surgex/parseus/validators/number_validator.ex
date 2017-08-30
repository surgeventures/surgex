defmodule Surgex.Parseus.NumberValidator do
  @moduledoc false

  def call(input, opts \\ [])
  def call(input, opts) do
    with :ok <- validate_type(input),
         :ok <- validate_min(input, Keyword.get(opts, :min)),
         :ok <- validate_max(input, Keyword.get(opts, :max))
    do
      :ok
    end
  end

  defp validate_type(input) when is_integer(input), do: :ok
  defp validate_type(input) when is_float(input), do: :ok
  defp validate_type(_), do: {:error, :type}

  defp validate_min(_input, nil), do: :ok
  defp validate_min(input, min) when input >= min, do: :ok
  defp validate_min(_input, _), do: {:error, :min}

  defp validate_max(_input, nil), do: :ok
  defp validate_max(input, max) when input <= max, do: :ok
  defp validate_max(_input, _), do: {:error, :max}
end
