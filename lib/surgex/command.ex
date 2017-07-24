defmodule Surgex.Command do
  @moduledoc false

  alias Surgex.Refactor

  def main(["refactor" | args]), do: Refactor.call(args)
  def main(_), do: raise(ArgumentError, "Unsupported command")
end
