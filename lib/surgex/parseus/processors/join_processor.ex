defmodule Surgex.Parseus.JoinProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output, mapping: mapping}, old_keys, new_key, opts) do
    new_mapping = update_mapping(mapping, old_keys, new_key)
    new_output = update_output(output, old_keys, new_key, opts)

    %{set | mapping: new_mapping, output: new_output}
  end

  defp update_mapping(mapping, old_keys, new_key) do
    Enum.reduce(old_keys, mapping, fn old_key, mapping ->
      map_value = Keyword.fetch!(mapping, old_key)
      mapping_without_old_key = Keyword.delete(mapping, old_key)

      [{new_key, map_value} | mapping_without_old_key]
    end)
  end

  defp update_output(output, old_keys, new_key, opts) do
    output_without_old_keys = Keyword.drop(output, old_keys)
    old_value_fetches = Enum.map(old_keys, &Keyword.fetch(output, &1))
    all_or_nothing = Keyword.get(opts, :all_or_nothing, true)
    put_new_key = !all_or_nothing || !Enum.find(old_value_fetches, &(&1 == :error))

    if put_new_key do
      old_values =
        old_value_fetches
        |> drop_missing_fetches(Keyword.get(opts, :drop_missing, false))
        |> Keyword.values()

      [{new_key, old_values} | output_without_old_keys]
    else
      output_without_old_keys
    end
  end

  defp drop_missing_fetches(fetches, false) do
    Enum.map(fetches, fn
      {:ok, value} -> {:ok, value}
      :error -> {:ok, nil}
    end)
  end
  defp drop_missing_fetches(fetches, true) do
    Enum.filter(fetches, fn fetch -> fetch != :error end)
  end
end
