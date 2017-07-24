defmodule Surgex.Parser.RequiredParserTest do
  use ExUnit.Case
  alias Surgex.Parser.RequiredParser

  test "valid input" do
    assert RequiredParser.call(123) == {:ok, 123}
    assert RequiredParser.call("abc") == {:ok, "abc"}
  end

  test "invalid input" do
    assert RequiredParser.call(nil) == {:error, :required}
    assert RequiredParser.call([]) == {:error, :required}
  end
end
