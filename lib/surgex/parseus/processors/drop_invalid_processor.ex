defmodule Surgex.Parseus.DropInvalidProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output}, nil), do: call(set, Keyword.keys(output))
  def call(set, key) when not(is_list(key)), do: call(set, [key])
  def call(set = %Set{output: output, errors: errors}, keys) do
    error_keys = Keyword.keys(errors)
    remove_keys = MapSet.intersection(MapSet.new(error_keys), MapSet.new(keys))
    new_output = Keyword.drop(output, remove_keys)

    %{set | output: new_output}
  end
end
