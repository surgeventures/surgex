defmodule Surgex.Parser.PageParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) ::
          {:ok, integer} | {:error, :invalid_page} | {:error, IntegerParser.errors()}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case IntegerParser.call(input) do
      {:ok, integer} when integer > 0 -> {:ok, integer}
      {:ok, _invalid_integer} -> {:error, :invalid_page}
      {:error, reason} -> {:error, reason}
    end
  end
end
