defmodule Mix.Tasks.Surgex.Refactor do
  @moduledoc """
  Runs tasks from the Surgex.Refactor module
  """

  use Mix.Task
  alias Surgex.Refactor

  @shortdoc "Runs tasks from the Surgex.Refactor module"

  def run(args) do
    Refactor.call(args)
  end
end
