defmodule Surgex.Parser.FloatParserTest do
  use ExUnit.Case
  alias Surgex.Parser.FloatParser

  test "nil" do
    assert FloatParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert FloatParser.call(2) == {:ok, 2.0}
    assert FloatParser.call(1, min: 0.9, max: 1.1) == {:ok, 1.0}
    assert FloatParser.call(12.34) == {:ok, 12.34}
    assert FloatParser.call("1") == {:ok, 1.0}
    assert FloatParser.call("1.5") == {:ok, 1.5}
    assert FloatParser.call("1.5", min: 1.5, max: 1.5) == {:ok, 1.5}
  end

  test "invalid input" do
    assert FloatParser.call("1.3a") == {:error, :invalid_float}
    assert FloatParser.call("x") == {:error, :invalid_float}
    assert FloatParser.call("") == {:error, :invalid_float}
    assert FloatParser.call(2, min: 0.9, max: 1.1) == {:error, :out_of_range}
    assert FloatParser.call("1.5", min: 1.6) == {:error, :out_of_range}
    assert FloatParser.call("1.5", max: 1.4) == {:error, :out_of_range}
  end
end
