defmodule Surgex.Parser.IdListParser do
  @moduledoc false

  alias Surgex.Parser.IdParser

  def call(nil), do: {:ok, []}
  def call(""), do: {:ok, []}
  def call(input) when is_binary(input) do
    input
    |> String.split(",")
    |> List.flatten
    |> Enum.reduce({:ok, []}, &reduce_ids/2)
    |> reverse
  end

  def reduce_ids(_, {:error, reason}) do
    {:error, reason}
  end
  def reduce_ids(id_string, {:ok, previous_ids}) do
    case IdParser.call(id_string) do
      {:ok, id} ->
        {:ok, [id | previous_ids]}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reverse({:ok, ids}), do: {:ok, Enum.reverse(ids)}
  defp reverse(error), do: error
end
