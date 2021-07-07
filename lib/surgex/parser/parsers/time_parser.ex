defmodule Surgex.Parser.TimeParser do
  @moduledoc false

  alias Surgex.Parser.IntegerParser

  @type errors :: :invalid_time | IntegerParser.errors()

  @day_secs 60 * 60 * 24

  @spec call(Surgex.Types.json_value()) :: {:ok, integer | nil} | {:error, errors}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    with {:ok, integer} <- IntegerParser.call(input) do
      call(integer)
    end
  end

  def call(secs) when is_integer(secs) and secs >= 0 and secs <= @day_secs, do: {:ok, secs}
  def call(secs) when is_integer(secs), do: {:error, :invalid_time}
  def call(_input), do: {:error, :invalid_time}
end
