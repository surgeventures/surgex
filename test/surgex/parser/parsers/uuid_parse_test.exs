defmodule Surgex.Parser.UuidParserTest do
  use ExUnit.Case, async: true
  alias Surgex.Parser.UuidParser

  test "nil" do
    assert UuidParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert UuidParser.call("") == {:ok, nil}
  end

  test "valid uuid" do
    uuid = "123e4567-e89b-12d3-a456-426614174000"
    assert UuidParser.call(uuid) == {:ok, uuid}
  end

  test "uuid with wrong hyphenation" do
    uuid = "123e4567-e89b-12d3-a456-42661417-4000"
    assert UuidParser.call(uuid) == {:error, :invalid_uuid}
  end

  test "uuid with characters out of range" do
    uuid = "123e4567-e89b-12d3-a456-426614174xyz"
    assert UuidParser.call(uuid) == {:error, :invalid_uuid}
  end

  test "uppercase uuid" do
    uuid = "123E4567-E89B-12D3-A456-426614174000"
    assert UuidParser.call(uuid) == {:ok, uuid}
  end

  test "not a string" do
    assert UuidParser.call(15) == {:error, :invalid_uuid}
  end
end
