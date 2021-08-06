defmodule Surgex.Parser.RequiredParser do
  @moduledoc false

  @spec call(any) :: {:ok, any} | {:error, :required}
  def call(nil), do: {:error, :required}
  def call(""), do: {:error, :required}
  def call([]), do: {:error, :required}
  def call(input), do: {:ok, input}
end
