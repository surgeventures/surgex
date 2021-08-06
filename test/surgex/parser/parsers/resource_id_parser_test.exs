defmodule Surgex.Parser.ResourceIdParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ResourceIdParser

  test "nil" do
    assert ResourceIdParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert ResourceIdParser.call(%{id: "123"}) == {:ok, 123}
  end

  test "invalid input" do
    assert ResourceIdParser.call(%{id: "0"}) == {:error, [invalid_identifier: "id"]}
    assert ResourceIdParser.call(%{id: nil}) == {:error, [required: "id"]}
    assert ResourceIdParser.call(%{id: ""}) == {:error, [required: "id"]}
    assert ResourceIdParser.call(%{}) == {:error, [required: "id"]}
  end
end
