defmodule Surgex.Parser.EmailParser do
  @moduledoc false

  alias Surgex.Parser.StringParser

  @email_regex ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/i

  @type errors :: :invalid_email | StringParser.errors()

  @spec call(term(), Keyword.t()) :: {:ok, String.t() | nil} | {:error, errors()}
  @spec call(any) :: {:ok, String.t() | nil} | {:error, errors()}
  def call(input), do: call(input, [])
  def call(nil, _), do: {:ok, nil}
  def call("", _), do: {:ok, nil}

  def call(input, opts) when is_binary(input) do
    case StringParser.call(input, Keyword.put(opts, :regex, @email_regex)) do
      {:ok, input} -> {:ok, input}
      {:error, :bad_format} -> {:error, :invalid_email}
      error -> error
    end
  end

  def call(_input, _), do: {:error, :invalid_email}
end
