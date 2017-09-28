defmodule Surgex.Parser.ListParser do
  @moduledoc false

  def call(nil), do: {:ok, []}
  def call(list) when is_list(list), do: {:ok, list}
  def call(string) when is_binary(string), do: {:ok, String.split(string, ",")}
end
