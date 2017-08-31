defmodule Surgex.Parseus.FormatValidator do
  @moduledoc false

  def call(input, format) do
    if String.match?(input, format) do
      :ok
    else
      {:error, nil, format: format}
    end
  end
end
