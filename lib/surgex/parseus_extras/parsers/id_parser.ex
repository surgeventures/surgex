defmodule Surgex.ParseusExtras.IdParser do
  @moduledoc false

  alias Surgex.Parseus.IntegerParser

  def call(input) when is_integer(input) and input > 0, do: {:ok, input}
  def call(input) when is_integer(input), do: {:error, :too_small}
  def call(input) when is_binary(input) do
    with {:ok, integer} when integer > 0 <- IntegerParser.call(input) do
      {:ok, integer}
    else
      {:ok, _invalid_integer} -> {:error, :too_small}
      _ -> {:error, :not_integer}
    end
  end
end
