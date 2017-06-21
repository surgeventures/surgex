defmodule Surgex.Parser.IntegerParser do
  @moduledoc false

  def call(nil), do: {:ok, nil}
  def call(input) when is_binary(input) do
    case Integer.parse(input) do
      {integer, ""} ->
        {:ok, integer}
      _ ->
        {:error, :invalid_integer}
    end
  end
end
