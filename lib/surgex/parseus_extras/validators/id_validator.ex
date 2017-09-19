defmodule Surgex.ParseusExtras.IdValidator do
  @moduledoc false

  def call(input) when is_integer(input) and input > 0, do: :ok
  def call(input) when is_integer(input), do: :error
end
