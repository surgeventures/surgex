defmodule Surgex.Parser.IdParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @type errors :: :invalid_identifier | IntegerParser.errors()
  @type option :: {:max, integer()}

  # This parser already validates that ids cannot be below zero
  # therefore we don't handle the Postgres min integer case
  @postgres_max_integer 2_147_483_647

  @spec call(term(), [option()]) :: {:ok, integer | nil} | {:error, errors}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call("", _opts), do: {:ok, nil}

  def call(input, opts) when is_binary(input) do
    max = Keyword.get(opts, :max, @postgres_max_integer)

    case IntegerParser.call(input, max: max) do
      {:ok, integer} when integer > 0 -> {:ok, integer}
      {:ok, _invalid_integer} -> {:error, :invalid_identifier}
      {:error, reason} -> {:error, reason}
    end
  end

  def call(_input, _opts), do: {:error, :invalid_identifier}
end
