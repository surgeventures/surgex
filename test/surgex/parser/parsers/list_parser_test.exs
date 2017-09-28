defmodule Surgex.Parser.ListParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ListParser

  test "nil" do
    assert ListParser.call(nil) == {:ok, []}
  end

  test "valid input" do
    assert ListParser.call(["a", 1]) == {:ok, ["a", 1]}
    assert ListParser.call("a,1") == {:ok, ["a", "1"]}
  end
end
