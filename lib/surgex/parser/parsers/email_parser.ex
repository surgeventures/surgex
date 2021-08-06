defmodule Surgex.Parser.EmailParser do
  @moduledoc false

  @email_regex ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/i

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) :: {:ok, String.t()} | {:error, :invalid_email}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    if Regex.match?(@email_regex, input) do
      {:ok, input}
    else
      {:error, :invalid_email}
    end
  end
end
