defmodule Surgex.Parser.EmailParser do
  @moduledoc false

  @email_regex ~r/^([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+$/i

  def call(nil), do: {:ok, nil}
  def call(input) when is_binary(input) do
    if Regex.match?(@email_regex, input) do
      {:ok, input}
    else
      {:error, :invalid_email}
    end
  end
end
