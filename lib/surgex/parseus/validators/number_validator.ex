defmodule Surgex.Parseus.NumberValidator do
  @moduledoc false

  def call(input, opts \\ [])
  def call(input, opts) do
    with :ok <- validate_eq(input, Keyword.get(opts, :equal_to)),
         :ok <- validate_gt(input, Keyword.get(opts, :greater_than)),
         :ok <- validate_ge(input, Keyword.get(opts, :greater_than_or_equal_to)),
         :ok <- validate_lt(input, Keyword.get(opts, :less_than)),
         :ok <- validate_le(input, Keyword.get(opts, :less_than_or_equal_to))
    do
      :ok
    end
  end

  defp validate_eq(_input, nil), do: :ok
  defp validate_eq(input, eq) when input == eq, do: :ok
  defp validate_eq(_input, eq), do: {:error, :not_equal_to, eq: eq}

  defp validate_gt(_input, nil), do: :ok
  defp validate_gt(input, min) when input > min, do: :ok
  defp validate_gt(_input, min), do: {:error, :not_greater_than, min: min}

  defp validate_ge(_input, nil), do: :ok
  defp validate_ge(input, min) when input >= min, do: :ok
  defp validate_ge(_input, min), do: {:error, :not_greater_than_or_equal_to, min_or_eq: min}

  defp validate_lt(_input, nil), do: :ok
  defp validate_lt(input, max) when input < max, do: :ok
  defp validate_lt(_input, max), do: {:error, :not_less_than, max: max}

  defp validate_le(_input, nil), do: :ok
  defp validate_le(input, max) when input <= max, do: :ok
  defp validate_le(_input, max), do: {:error, :not_less_than_or_equal_to, max_or_eq: max}
end
