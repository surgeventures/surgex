defmodule Surgex.Parser.IdParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @type errors :: :invalid_identifier | :invalid_max | IntegerParser.errors()
  @type numeric_id_types :: :int | :integer | :bigint | :biginteger | :serial | :bigserial
  @type option :: {:max, integer() | numeric_id_types()}

  # This parser already validates that ids cannot be below zero
  # therefore we don't handle the minimum case
  # See reference here for numeric types: https://www.postgresql.org/docs/current/datatype-numeric.html

  @int8_max 9_223_372_036_854_775_807
  @int4_max 2_147_483_647

  @numeric_type_to_max_size %{
    bigint: @int8_max,
    biginteger: @int8_max,
    bigserial: @int8_max,
    int: @int4_max,
    integer: @int4_max,
    serial: @int4_max
  }

  @spec call(term(), [option()]) :: {:ok, integer | nil} | {:error, errors}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call("", _opts), do: {:ok, nil}

  def call(input, opts) when is_binary(input) do
    max = Keyword.get(opts, :max)

    with {:ok, max} <- parse_max(max) do
      case IntegerParser.call(input, max: max) do
        {:ok, integer} when integer > 0 -> {:ok, integer}
        {:ok, _invalid_integer} -> {:error, :invalid_identifier}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def call(_input, _opts), do: {:error, :invalid_identifier}

  def parse_max(max) when is_integer(max), do: {:ok, max}

  for {type, size} <- @numeric_type_to_max_size do
    def parse_max(unquote(type)), do: {:ok, unquote(size)}
  end

  def parse_max(nil), do: {:ok, nil}

  def parse_max(_max), do: {:error, :invalid_max}
end
