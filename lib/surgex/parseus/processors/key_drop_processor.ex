defmodule Surgex.Parseus.KeyDropProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px, keys) when is_list(keys) do
    Enum.reduce(keys, px, &call(&2, &1))
  end
  def call(px = %Parseus{output: output}, key) do
    new_output = Keyword.delete(output, key)

    %{px | output: new_output}
  end
end
