defmodule Surgex.Parser.IdListParser do
  @moduledoc false

  alias Surgex.Parser.IdParser

  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, []}
  def call("", _opts), do: {:ok, []}

  def call(input, opts) when is_binary(input) do
    input
    |> String.split(",")
    |> Enum.reduce({:ok, []}, &reduce_ids/2)
    |> reverse
    |> check_max(Keyword.get(opts, :max))
  end

  defp reduce_ids(_, {:error, reason}) do
    {:error, reason}
  end

  defp reduce_ids(id_string, {:ok, previous_ids}) do
    case IdParser.call(id_string) do
      {:ok, id} ->
        {:ok, [id | previous_ids]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reverse({:ok, ids}), do: {:ok, Enum.reverse(ids)}
  defp reverse(error), do: error

  defp check_max({:ok, ids}, limit) when is_integer(limit) and length(ids) > limit do
    {:error, :invalid_id_list_length}
  end

  defp check_max(ok_or_error, _limit_or_nil), do: ok_or_error
end
