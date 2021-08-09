defmodule Surgex.Parser.RequiredParser do
  @moduledoc false

  @spec call(term()) :: {:ok, term()} | {:error, :required}
  def call(nil), do: {:error, :required}
  def call(""), do: {:error, :required}
  def call([]), do: {:error, :required}
  def call(input), do: {:ok, input}
end
