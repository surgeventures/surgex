defmodule Surgex.Parser.ListParser do
  @moduledoc false

  @spec call(any) :: {:ok, [any]} | {:error, :invalid_list}
  def call(nil), do: {:ok, []}
  def call(list) when is_list(list), do: {:ok, list}
  def call(""), do: {:ok, []}
  def call(string) when is_binary(string), do: {:ok, String.split(string, ",")}
  def call(_input), do: {:error, :invalid_list}
end
