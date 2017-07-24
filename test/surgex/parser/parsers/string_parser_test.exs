defmodule Surgex.Parser.StringParserTest do
  use ExUnit.Case
  alias Surgex.Parser.StringParser

  test "nil" do
    assert StringParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert StringParser.call("") == {:ok, nil}
    assert StringParser.call("abc") == {:ok, "abc"}
  end
end
