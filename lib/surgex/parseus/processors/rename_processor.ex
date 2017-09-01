defmodule Surgex.Parseus.RenameProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output, mapping: mapping}, old_key, new_key) do
    map_value = Keyword.fetch!(mapping, old_key)
    new_mapping =
      mapping
      |> Keyword.delete(old_key)
      |> Keyword.put(new_key, map_value)

    new_output = case Keyword.fetch(output, old_key) do
      {:ok, value} ->
        output
        |> Keyword.delete(old_key)
        |> Keyword.put(new_key, value)
      :error ->
        output
    end

    %{set | mapping: new_mapping, output: new_output}
  end
end
