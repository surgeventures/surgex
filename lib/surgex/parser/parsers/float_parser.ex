defmodule Surgex.Parser.FloatParser do
  @moduledoc false

  def call(nil), do: {:ok, nil}
  def call(input) when is_binary(input) do
    case Float.parse(input) do
      {float, ""} ->
        {:ok, float}
      _ ->
        {:error, :invalid_float}
    end
  end
end
