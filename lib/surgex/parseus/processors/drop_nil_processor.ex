defmodule Surgex.Parseus.DropNilProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output}, nil), do: call(set, Keyword.keys(output))
  def call(set, key) when not(is_list(key)), do: call(set, [key])
  def call(set = %Set{output: output}, keys) do
    nil_keys = Enum.filter(keys, fn key -> is_nil(output[key]) end)
    new_output = Keyword.drop(output, nil_keys)

    %{set | output: new_output}
  end
end
