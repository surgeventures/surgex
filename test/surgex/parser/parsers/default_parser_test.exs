defmodule Surgex.Parser.DefaultParserTest do
  use ExUnit.Case
  alias Surgex.Parser.DefaultParser

  test "returns default value for an empty input" do
    assert DefaultParser.call(nil, "default") == {:ok, "default"}
    assert DefaultParser.call(" ", "default") == {:ok, "default"}
    assert DefaultParser.call([], "default", empty_values: [[]]) == {:ok, "default"}
    assert DefaultParser.call(:empty, "default", empty_values: [:empty]) == {:ok, "default"}
  end

  test "passes through any non-empty input" do
    assert DefaultParser.call("a value", "default") == {:ok, "a value"}
    assert DefaultParser.call([], "default") == {:ok, []}
    assert DefaultParser.call(false, "default") == {:ok, false}
    assert DefaultParser.call("", "default", empty_values: [:empty]) == {:ok, ""}
    assert DefaultParser.call(nil, "default", empty_values: [:empty]) == {:ok, nil}
  end
end
