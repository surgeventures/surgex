defmodule Surgex.Parser.StringParser do
  @moduledoc false

  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}
  def call("", :allow_empty), do: {:ok, ""}
  def call("", _opts), do: {:ok, nil}
  def call(input, _opts) when is_binary(input), do: {:ok, input}
end
