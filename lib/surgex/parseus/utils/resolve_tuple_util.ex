defmodule Surgex.Parseus.ResolveTupleUtil do
  alias Surgex.Parseus.Set

  def call(set, key) when not(is_list(key)), do: call(set, [key])
  def call(%Set{errors: [], output: output}, keys) do
    values = Enum.reduce(keys, [], fn key, values ->
      [Keyword.get(output, key) | values]
    end)

    List.to_tuple([:ok | Enum.reverse(values)])
  end
  def call(set, _), do: {:error, set}
end
