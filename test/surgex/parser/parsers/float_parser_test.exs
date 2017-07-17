defmodule Surgex.Parser.FloatParserTest do
  use ExUnit.Case
  alias Surgex.Parser.FloatParser

  test "nil" do
    assert FloatParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert FloatParser.call("1") == {:ok, 1.0}
    assert FloatParser.call("1.5") == {:ok, 1.5}
  end

  test "invalid input" do
    assert FloatParser.call("1.3a") == {:error, :invalid_float}
    assert FloatParser.call("x") == {:error, :invalid_float}
    assert FloatParser.call("") == {:error, :invalid_float}
  end
end
