defmodule Surgex.Parseus.InclusionValidator do
  @moduledoc false

  def call(input, allowed_values) do
    if input in allowed_values do
      :ok
    else
      {:error, nil, allowed_values: allowed_values}
    end
  end
end
