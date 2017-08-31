defmodule Surgex.Parseus.BooleanValidator do
  @moduledoc false

  def call(true), do: :ok
  def call(false), do: :ok
  def call(_), do: :error
end
