defmodule Surgex.Parser.EmailParserTest do
  use ExUnit.Case
  alias Surgex.Parser.EmailParser

  test "nil" do
    assert EmailParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert EmailParser.call("me@example.com") == {:ok, "me@example.com"}
  end

  test "invalid input" do
    assert EmailParser.call("me") == {:error, :invalid_email}
    assert EmailParser.call("me@example") == {:error, :invalid_email}
    assert EmailParser.call("example.com") == {:error, :invalid_email}
  end
end
