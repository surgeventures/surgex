defmodule Mix.Tasks.Surgex.Refactor do
  use Mix.Task
  alias Surgex.Refactor

  def run(args) do
    Refactor.call(args)
  end
end
