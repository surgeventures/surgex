defmodule Surgex.ParseusExtras.EmailValidator do
  @moduledoc false

  @email_regex ~r/^([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+$/i

  def call(input) when is_binary(input) do
    if Regex.match?(@email_regex, input) do
      :ok
    else
      :error
    end
  end
end
