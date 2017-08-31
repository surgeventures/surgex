defmodule Surgex.Parseus.ExclusionValidator do
  @moduledoc false

  def call(input, forbidden_values) do
    if input in forbidden_values do
      {:error, nil, forbidden_values: forbidden_values}
    else
      :ok
    end
  end
end
