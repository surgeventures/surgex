defmodule Surgex.Parser.SlugOrIdParser do
  @moduledoc false

  alias Surgex.Parser.IdParser

  @spec call(term()) :: {:ok, String.t() | nil} | {:error, :invalid_slug}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    cond do
      String.match?(input, ~r/^\d+$/) ->
        IdParser.call(input)

      String.match?(input, ~r/^[a-zA-Z0-9\-]+$/) ->
        {:ok, input}

      true ->
        {:error, :invalid_slug}
    end
  end

  def call(_input), do: {:error, :invalid_slug}
end
