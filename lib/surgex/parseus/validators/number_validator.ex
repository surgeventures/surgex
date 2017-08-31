defmodule Surgex.Parseus.NumberValidator do
  @moduledoc false

  def call(input, opts \\ [])
  def call(input, opts) do
    with :ok <- validate_type(input, Keyword.get(opts, :type)),
         :ok <- validate_eq(input, Keyword.get(opts, :equal_to)),
         :ok <- validate_gt(input, Keyword.get(opts, :greater_than)),
         :ok <- validate_ge(input, Keyword.get(opts, :greater_than_or_equal_to)),
         :ok <- validate_lt(input, Keyword.get(opts, :less_than)),
         :ok <- validate_le(input, Keyword.get(opts, :less_than_or_equal_to))
    do
      :ok
    end
  end

  defp validate_type(input, nil) when is_integer(input), do: :ok
  defp validate_type(input, nil) when is_float(input), do: :ok
  defp validate_type(input, :integer) when is_integer(input), do: :ok
  defp validate_type(input, :float) when is_float(input), do: :ok
  defp validate_type(_), do: {:error, :invalid_type}

  defp validate_eq(_input, nil), do: :ok
  defp validate_eq(input, eq) when input == eq, do: :ok
  defp validate_eq(_input, _), do: {:error, :not_equal_to}

  defp validate_gt(_input, nil), do: :ok
  defp validate_gt(input, min) when input > min, do: :ok
  defp validate_gt(_input, _), do: {:error, :not_greater_than}

  defp validate_ge(_input, nil), do: :ok
  defp validate_ge(input, min) when input >= min, do: :ok
  defp validate_ge(_input, _), do: {:error, :not_greater_than_or_equal_to}

  defp validate_lt(_input, nil), do: :ok
  defp validate_lt(input, max) when input < max, do: :ok
  defp validate_lt(_input, _), do: {:error, :not_less_than}

  defp validate_le(_input, nil), do: :ok
  defp validate_le(input, max) when input <= max, do: :ok
  defp validate_le(_input, _), do: {:error, :not_less_than_or_equal_to}
end
