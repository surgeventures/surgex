defmodule Surgex.Parser.IntegerParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IntegerParser

  test "nil" do
    assert IntegerParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert IntegerParser.call("123") == {:ok, 123}
  end

  test "invalid input" do
    assert IntegerParser.call("123.0") == {:error, :invalid_integer}
    assert IntegerParser.call("123abc") == {:error, :invalid_integer}
    assert IntegerParser.call("?") == {:error, :invalid_integer}
  end
end
