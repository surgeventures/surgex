defmodule Surgex.Parser.ContainParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ContainParser

  test "nil" do
    assert ContainParser.call(nil, ["allowed value"]) == {:error, :value_is_not_allowed}
  end

  test "empty array of allowed values" do
    assert ContainParser.call("value", []) == {:error, :value_is_not_allowed}
  end

  test "allowed values not a list" do
    assert ContainParser.call("value", "not a list") == {:error, :allowed_values_is_not_a_list}
  end

  test "valid input is on the list of allowed values" do
    assert ContainParser.call("value", ["value"]) == {:ok, "value"}
  end

  test "valid input is not on the list of allowed values" do
    assert ContainParser.call("value", ["different_value"]) == {:error, :value_is_not_allowed}
  end
end
