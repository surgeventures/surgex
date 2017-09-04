defmodule Surgex.Parseus.ResolveUtil do
  alias Surgex.Parseus.Set

  def call(%Set{errors: [], output: output}), do: {:ok, output}
  def call(set), do: {:error, set}
end
