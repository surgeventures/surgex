defmodule Surgex.Parser.DateParser do
  @moduledoc false

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) :: {:ok, Date.t()} | {:ok, :invalid_date}
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
