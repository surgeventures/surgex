defmodule Surgex.Command do
  alias Surgex.Refactor

  def main(["refactor" | args]), do: Refactor.call(args)
  def main(_), do: raise(ArgumentError, "Unsupported command")
end
