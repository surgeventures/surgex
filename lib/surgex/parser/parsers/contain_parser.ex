defmodule Surgex.Parser.ContainParser do
  @moduledoc """
  Checks if the given parameter's value is on the list of allowed values
  """

  def call(nil, _allowed_values), do: {:error, :value_is_not_allowed}
  def call(_, []), do: {:error, :value_is_not_allowed}
  def call(input, allowed_values) when is_list(allowed_values) do
    case Enum.member?(allowed_values, input) do
      true -> {:ok, input}
      false -> {:error, :value_is_not_allowed}
    end
  end
  def call(_input, _allowed_values), do: {:error, :allowed_values_is_not_a_list}
end
