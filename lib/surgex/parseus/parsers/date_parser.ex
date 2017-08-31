defmodule Surgex.Parseus.DateParser do
  @moduledoc false

  def call(input) when is_binary(input) do
    case Date.from_iso8601(input) do
      {:ok, date} ->
        {:ok, date}
      {:error, _reason} ->
        :error
    end
  end
end
