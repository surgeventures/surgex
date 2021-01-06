defmodule Surgex.Parser.DateParserTest do
  use ExUnit.Case
  alias Surgex.Parser.DateParser

  test "nil" do
    assert DateParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert DateParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert DateParser.call("2015-01-01") == {:ok, ~D[2015-01-01]}
  end

  test "invalid input" do
    assert DateParser.call("2015-1-1") == {:error, :invalid_date}
    assert DateParser.call("2015-02-30") == {:error, :invalid_date}
    assert DateParser.call("abc") == {:error, :invalid_date}
  end
end
