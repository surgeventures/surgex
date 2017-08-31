defmodule Surgex.Parseus.FloatParser do
  @moduledoc false

  def call(input) when is_binary(input) do
    case Float.parse(input) do
      {output, ""} ->
        {:ok, output}
      _ ->
        :error
    end
  end
end
