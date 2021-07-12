defmodule Surgex.Parser.DateParser do
  @moduledoc false

  @spec call(term()) :: {:ok, Date.t() | nil} | {:error, :invalid_date}
  def call(nil), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case Date.from_iso8601(input) do
      {:ok, date} ->
        {:ok, date}

      {:error, _reason} ->
        {:error, :invalid_date}
    end
  end

  def call(_input), do: {:error, :invalid_date}
end
