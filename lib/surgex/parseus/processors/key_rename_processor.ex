defmodule Surgex.Parseus.KeyRenameProcessor do
  alias Surgex.Parseus

  def call(px = %Parseus{output: output, mapping: mapping}, old_key, new_key) do
    map_value = Keyword.fetch!(mapping, old_key)
    new_mapping =
      mapping
      |> Keyword.delete(old_key)
      |> Keyword.put(new_key, map_value)

    new_result = case Keyword.fetch(output, old_key) do
      {:ok, value} ->
        output
        |> Keyword.delete(old_key)
        |> Keyword.put(new_key, value)
      :error ->
        output
    end

    %{px | mapping: new_mapping, output: new_result}
  end
end
