defmodule Surgex.Parser.SlugParser do
  @moduledoc false

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) :: {:ok, String.t()} | {:error, :invalid_slug}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    if String.match?(input, ~r/^[a-zA-Z0-9\-]+$/) do
      {:ok, input}
    else
      {:error, :invalid_slug}
    end
  end
end
