defmodule Surgex.Parser.ContainParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ContainParser

  test "nil" do
    assert ContainParser.call(nil, ["allowed value"]) == {:ok, nil}
  end

  test "empty string" do
    assert ContainParser.call("", ["allowed value"]) == {:ok, nil}
  end

  test "empty array of allowed values" do
    assert ContainParser.call("value", []) == {:error, :invalid_value}
  end

  test "valid input is on the list of allowed values" do
    assert ContainParser.call("value", ["value"]) == {:ok, "value"}
  end

  test "valid input is not on the list of allowed values" do
    assert ContainParser.call("value", ["different_value"]) == {:error, :invalid_value}
  end
end
