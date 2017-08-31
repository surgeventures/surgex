defmodule Surgex.Parseus.RequiredValidator do
  @moduledoc false

  def call(input, key) when is_atom(key), do: call(input, [key])
  def call(input, keys) when is_list(keys) do
    case get_errors(input, keys) do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp get_errors(input, keys) do
    Enum.reduce(keys, [], fn key, errors ->
      if Keyword.has_key?(input, key) do
        errors
      else
        [{key, nil} | errors]
      end
    end)
  end
end
