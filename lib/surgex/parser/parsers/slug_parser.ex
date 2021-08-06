defmodule Surgex.Parser.SlugParser do
  @moduledoc false

  @spec call(term()) :: {:ok, String.t() | nil} | {:error, :invalid_slug}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    if String.match?(input, ~r/^[a-zA-Z0-9\-]+$/) do
      {:ok, input}
    else
      {:error, :invalid_slug}
    end
  end

  def call(_input), do: {:error, :invalid_slug}
end
