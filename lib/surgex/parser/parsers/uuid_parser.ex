defmodule Surgex.Parser.UuidParser do
  @moduledoc """
  This parser checks if the input is a proper UUID (with hyphens, case insentitive)
  """

  alias Surgex.Parser.StringParser

  @uuid_regex ~r/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i

  @spec call(term()) :: {:ok, String.t() | nil} | {:error, :invalid_uuid}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case StringParser.call(input, regex: @uuid_regex) do
      {:ok, input} -> {:ok, input}
      {:error, :bad_format} -> {:error, :invalid_uuid}
    end
  end

  def call(_), do: {:error, :invalid_uuid}
end
