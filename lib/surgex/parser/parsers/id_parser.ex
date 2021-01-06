defmodule Surgex.Parser.IdParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @type errors :: :invalid_identifier | IntegerParser.errors()

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) :: {:ok, integer} | {:error, errors}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    with {:ok, integer} when integer > 0 <- IntegerParser.call(input) do
      {:ok, integer}
    else
      {:ok, _invalid_integer} -> {:error, :invalid_identifier}
      {:error, reason} -> {:error, reason}
    end
  end
end
