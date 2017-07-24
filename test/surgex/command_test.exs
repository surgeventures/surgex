defmodule Surgex.CommandTest do
  use ExUnit.Case
  alias Surgex.Command

  test "refactor" do
    assert_raise(ArgumentError, ~r/No refactor task/, fn ->
      Command.main(["refactor"])
    end)
  end

  test "wrong command" do
    assert_raise(ArgumentError, ~r/Unsupported command/, fn ->
      Command.main([])
    end)
  end
end
