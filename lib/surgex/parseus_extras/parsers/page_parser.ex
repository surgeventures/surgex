defmodule Surgex.ParseusExtras.PageParser do
  @moduledoc false

  def call(input) when is_integer(input) and input > 0, do: {:ok, input}
  def call(input) when is_integer(input), do: {:error, :too_small}
  def call(input) when is_binary(input) do
    with {:ok, integer} when integer > 0 <- Surgex.Parseus.IntegerParser.call(input) do
      {:ok, integer}
    else
      {:ok, _invalid_integer} -> {:error, :too_small}
      _ -> {:error, :not_integer}
    end
  end
end
