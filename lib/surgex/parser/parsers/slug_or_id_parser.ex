defmodule Surgex.Parser.SlugOrIdParser do
  @moduledoc false

  alias Surgex.Parser.IdParser

  @spec call(term(), [IdParser.option()]) ::
          {:ok, String.t() | nil} | {:error, :invalid_slug | IdParser.errors()}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call("", _opts), do: {:ok, nil}

  def call(input, opts) when is_binary(input) do
    cond do
      String.match?(input, ~r/^\d+$/) ->
        IdParser.call(input, opts)

      String.match?(input, ~r/^[a-zA-Z0-9\-]+$/) ->
        {:ok, input}

      true ->
        {:error, :invalid_slug}
    end
  end

  def call(_input, _opts), do: {:error, :invalid_slug}
end
