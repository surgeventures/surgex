defmodule Surgex.Parser.BooleanParserTest do
  use ExUnit.Case
  alias Surgex.Parser.BooleanParser

  test "nil" do
    assert BooleanParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert BooleanParser.call("0") == {:ok, false}
    assert BooleanParser.call("1") == {:ok, true}
    assert BooleanParser.call(false) == {:ok, false}
    assert BooleanParser.call(true) == {:ok, true}
  end

  test "invalid input" do
    assert BooleanParser.call("?") == {:error, :invalid_boolean}
    assert BooleanParser.call(2) == {:error, :invalid_boolean}
    assert BooleanParser.call(0.5) == {:error, :invalid_boolean}
  end
end
