defmodule Surgex.Parseus.DropProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set, keys) when is_list(keys) do
    Enum.reduce(keys, set, &call(&2, &1))
  end
  def call(set = %Set{output: output}, key) do
    new_output = Keyword.delete(output, key)

    %{set | output: new_output}
  end
end
