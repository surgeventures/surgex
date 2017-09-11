defmodule Surgex.Parseus.BlankStringToNilMapper do
  @moduledoc false

  def call(""), do: nil
  def call(any), do: any
end
