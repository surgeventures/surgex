defmodule Surgex.Parser.IdListParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IdListParser

  test "nil" do
    assert IdListParser.call(nil) == {:ok, []}
  end

  test "empty string" do
    assert IdListParser.call("") == {:ok, []}
  end

  test "valid input" do
    assert IdListParser.call("") == {:ok, []}
    assert IdListParser.call("123") == {:ok, [123]}
    assert IdListParser.call("123,456") == {:ok, [123, 456]}
    assert IdListParser.call("123,456", max: 2) == {:ok, [123, 456]}

    assert IdListParser.call([]) == {:ok, []}
    assert IdListParser.call([1, 2, 3]) == {:ok, [1, 2, 3]}
    assert IdListParser.call(["1", "2", "3"]) == {:ok, [1, 2, 3]}
  end

  test "invalid input" do
    assert IdListParser.call("123,456.0") == {:error, :invalid_integer}
    assert IdListParser.call("123,abc") == {:error, :invalid_integer}
    assert IdListParser.call("abc") == {:error, :invalid_integer}
    assert IdListParser.call("123,456,789", max: 2) == {:error, :invalid_id_list_length}
    assert IdListParser.call(["1", "2", "three"]) == {:error, :invalid_integer}
    assert IdListParser.call([1, -2, 3]) == {:error, :invalid_identifier}
    assert IdListParser.call(["1", "-2", "3"]) == {:error, :invalid_identifier}
  end
end
