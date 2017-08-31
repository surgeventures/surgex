defmodule Surgex.Parseus.BooleanParser do
  @moduledoc false

  def call("0"), do: {:ok, false}
  def call("1"), do: {:ok, true}
  def call(_), do: :error
end
