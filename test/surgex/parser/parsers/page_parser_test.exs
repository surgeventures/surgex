defmodule Surgex.Parser.PageParserTest do
  use ExUnit.Case
  alias Surgex.Parser.PageParser

  test "nil" do
    assert PageParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert PageParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert PageParser.call("123") == {:ok, 123}
  end

  test "invalid input" do
    assert PageParser.call("0") == {:error, :invalid_page}
    assert PageParser.call("123.0") == {:error, :invalid_integer}
    assert PageParser.call("123abc") == {:error, :invalid_integer}
    assert PageParser.call("?") == {:error, :invalid_integer}
  end

  test "unsupported input type" do
    assert PageParser.call(1.5) == {:error, :invalid_page}
    assert PageParser.call([1]) == {:error, :invalid_page}
  end
end
