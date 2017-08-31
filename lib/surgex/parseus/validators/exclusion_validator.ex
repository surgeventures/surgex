defmodule Surgex.Parseus.ExclusionValidator do
  @moduledoc false

  def call(input, forbidden_values) do
    if input in forbidden_values do
      :error
    else
      :ok
    end
  end
end
