defmodule Surgex.Parseus.FilterProcessor do
  @moduledoc false

  alias Surgex.Parseus.{
    CallUtil,
    Set,
  }

  def call(set, keys, filterer) when is_list(keys) do
    Enum.reduce(keys, set, &call(&2, &1, filterer))
  end
  def call(set = %Set{output: output}, key, filterer) do
    with {:ok, old_value} <- Keyword.fetch(output, key) do
      filterer
      |> CallUtil.call(old_value)
      |> handle_result(set, key)
    else
      _ -> set
    end
  end

  defp handle_result(result, set = %Set{output: output}, key) do
    if result do
      set
    else
      %{set | output: Keyword.delete(output, key)}
    end
  end
end
