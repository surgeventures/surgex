defmodule Surgex.Parser.IdParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @type errors :: :invalid_identifier | IntegerParser.errors()

  @spec call(term()) :: {:ok, integer | nil} | {:error, errors}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case IntegerParser.call(input) do
      {:ok, integer} when integer > 0 -> {:ok, integer}
      {:ok, _invalid_integer} -> {:error, :invalid_identifier}
      {:error, reason} -> {:error, reason}
    end
  end

  def call(_input), do: {:error, :invalid_identifier}
end
