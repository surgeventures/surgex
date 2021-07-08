defmodule Surgex.Parser.EmailParser do
  @moduledoc false

  @email_regex ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/i

  @spec call(Surgex.Types.json_value()) :: {:ok, String.t() | nil} | {:error, :invalid_email}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    if Regex.match?(@email_regex, input) do
      {:ok, input}
    else
      {:error, :invalid_email}
    end
  end

  def call(_input), do: {:error, :invalid_email}
end
