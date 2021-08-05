defmodule Surgex.Parser.IntegerParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IntegerParser

  test "nil" do
    assert IntegerParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert IntegerParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert IntegerParser.call(123) == {:ok, 123}
    assert IntegerParser.call("123") == {:ok, 123}
    assert IntegerParser.call("123", min: 123, max: 123) == {:ok, 123}
  end

  test "invalid input" do
    assert IntegerParser.call("123.0") == {:error, :invalid_integer}
    assert IntegerParser.call("123abc") == {:error, :invalid_integer}
    assert IntegerParser.call("?") == {:error, :invalid_integer}
    assert IntegerParser.call("1", min: 2) == {:error, :out_of_range}
    assert IntegerParser.call("1", max: 0) == {:error, :out_of_range}
  end
end
