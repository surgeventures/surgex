defmodule Surgex.Parser.IdParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IdParser

  test "nil" do
    assert IdParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert IdParser.call("123") == {:ok, 123}
  end

  test "invalid input" do
    assert IdParser.call("-1") == {:error, :invalid_identifier}
    assert IdParser.call("123abc") == {:error, :invalid_integer}
    assert IdParser.call("?") == {:error, :invalid_integer}
  end

  test "unsupported input type" do
    assert IdParser.call(1.5) == {:error, :invalid_identifier}
    assert IdParser.call(["1"]) == {:error, :invalid_identifier}
  end
end
