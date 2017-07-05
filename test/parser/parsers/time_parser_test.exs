defmodule Surgex.Parser.TimeParserTest do
  use ExUnit.Case
  alias Surgex.Parser.TimeParser

  test "nil" do
    assert TimeParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert TimeParser.call("0") == {:ok, 0}
    assert TimeParser.call(0) == {:ok, 0}
    assert TimeParser.call(Integer.to_string(24 * 60 * 60 - 1)) == {:ok, 24 * 60 * 60 - 1}
  end

  test "invalid input" do
    assert TimeParser.call("abc") == {:error, :invalid_integer}
    assert TimeParser.call(Integer.to_string(24 * 60 * 60 + 1)) == {:error, :invalid_time}
  end
end
