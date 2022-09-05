defmodule Surgex.Parser.DefaultParser do
  @moduledoc """
  Return default value for an empty input.
  """

  @empty_values [nil, ""]

  @spec call(term(), term(), Keyword.t()) :: {:ok, term()}
  def call(input_value, default_input_value, opts \\ []) do
    empty_values = Keyword.get(opts, :empty_values, @empty_values)

    if trim(input_value) in empty_values do
      {:ok, default_input_value}
    else
      {:ok, input_value}
    end
  end

  defp trim(input_value) when is_binary(input_value), do: String.trim(input_value)
  defp trim(input_value), do: input_value
end
