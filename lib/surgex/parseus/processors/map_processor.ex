defmodule Surgex.Parseus.MapProcessor do
  @moduledoc false

  alias Surgex.Parseus.{
    CallUtil,
    Set,
  }

  def call(set, keys, mapper) when is_list(keys) do
    Enum.reduce(keys, set, &call(&2, &1, mapper))
  end
  def call(set = %Set{output: output, errors: errors}, key, mapper) do
    with false <- Keyword.has_key?(errors, key),
         {:ok, old_value} <- Keyword.fetch(output, key)
    do
      mapper
      |> CallUtil.call(old_value)
      |> handle_result(set, key)
    else
      _ -> set
    end
  end

  defp handle_result(new_value, set = %Set{output: output}, key) do
    new_output = Keyword.put(output, key, new_value)
    %{set | output: new_output}
  end
end
