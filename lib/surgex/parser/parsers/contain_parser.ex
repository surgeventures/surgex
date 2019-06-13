defmodule Surgex.Parser.ContainParser do
  @moduledoc """
  Checks if the given parameter's value is on the list of allowed values.
  """

  @doc false
  @spec call(nil, any) :: {:ok, nil} | {:ok, any} | {:error, :invalid_value}
  def call(nil, _allowed_values), do: {:ok, nil}

  def call(input, allowed_values) when is_list(allowed_values) do
    case Enum.member?(allowed_values, input) do
      true -> {:ok, input}
      false -> {:error, :invalid_value}
    end
  end
end
