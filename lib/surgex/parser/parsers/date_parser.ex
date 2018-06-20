defmodule Surgex.Parser.DateParser do
  @moduledoc false

  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case Date.from_iso8601(input) do
      {:ok, date} ->
        {:ok, date}

      {:error, _reason} ->
        {:error, :invalid_date}
    end
  end
end
