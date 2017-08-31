defmodule Surgex.Parseus.LengthValidator do
  @moduledoc false

  def call(input, opts \\ [])
  def call(input, opts) do
    with :ok <- validate_is(input, Keyword.get(opts, :is)),
         :ok <- validate_min(input, Keyword.get(opts, :min)),
         :ok <- validate_max(input, Keyword.get(opts, :max))
    do
      :ok
    end
  end

  defp validate_is(_input, nil), do: :ok
  defp validate_is(input, max) do
    if String.length(input) == max do
      :ok
    else
      {:error, :not_equal}
    end
  end

  defp validate_min(_input, nil), do: :ok
  defp validate_min(input, max) do
    if String.length(input) >= max do
      :ok
    else
      {:error, :not_within_max}
    end
  end

  defp validate_max(_input, nil), do: :ok
  defp validate_max(input, max) do
    if String.length(input) <= max do
      :ok
    else
      {:error, :not_within_min}
    end
  end
end
