defmodule Mix.Tasks.Surgex.RefactorTest do
  use ExUnit.Case
  alias Mix.Tasks.Surgex.Refactor

  test "calls Surgex.Refactor" do
    assert_raise(ArgumentError, ~r/No refactor task/, fn ->
      Refactor.run([])
    end)
  end
end
