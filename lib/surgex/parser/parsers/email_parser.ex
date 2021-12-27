defmodule Surgex.Parser.EmailParser do
  @moduledoc false

  alias Surgex.Parser.StringParser

  @email_regex ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/i

  @spec call(term()) :: {:ok, String.t() | nil} | {:error, :invalid_email}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case StringParser.call(input, regex: @email_regex) do
      {:ok, input} -> {:ok, input}
      {:error, :bad_format} -> {:error, :invalid_email}
    end
  end

  def call(_input), do: {:error, :invalid_email}
end
