defmodule Surgex.Parseus.ForkProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output, mapping: mapping}, source_key, target_key) do
    new_mapping = update_mapping(mapping, source_key, target_key)
    new_output = update_output(output, source_key, target_key)

    %{set | output: new_output, mapping: new_mapping}
  end

  defp update_mapping(mapping, source_key, target_key) do
    map_value = Keyword.fetch!(mapping, source_key)

    Keyword.put(mapping, target_key, map_value)
  end

  defp update_output(output, source_key, target_key) do
    case Keyword.fetch(output, source_key) do
      {:ok, value} ->
        Keyword.put(output, target_key, value)
      :error ->
        output
    end
  end
end
