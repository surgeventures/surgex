defmodule Surgex.Parser.BooleanParser do
  @moduledoc false

  @spec call(nil) :: {:ok, nil}
  @spec call(true) :: {:ok, true}
  @spec call(false) :: {:ok, false}
  @spec call(String.t()) :: {:ok, true | false} :: {:error, :invalid_boolean}
  def call(nil), do: {:ok, nil}
  def call("0"), do: {:ok, false}
  def call("1"), do: {:ok, true}
  def call(false), do: {:ok, false}
  def call(true), do: {:ok, true}
  def call(_input), do: {:error, :invalid_boolean}
end
