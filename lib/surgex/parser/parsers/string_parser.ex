defmodule Surgex.Parser.StringParser do
  @moduledoc false

  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}
  def call(input) when is_binary(input), do: {:ok, input}
end
