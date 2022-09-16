defmodule Surgex.Parser.IdParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IdParser

  test "nil" do
    assert IdParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert IdParser.call("") == {:ok, nil}
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

  @postgres_max_integer 2_147_483_647

  test "by default enforces max based on 4 byte signed integers" do
    assert IdParser.call(to_string(@postgres_max_integer)) == {:ok, @postgres_max_integer}
    assert IdParser.call(to_string(@postgres_max_integer + 1)) == {:error, :out_of_range}
  end

  test "max is overridable" do
    new_max = @postgres_max_integer + 1

    assert IdParser.call(to_string(new_max), max: new_max) == {:ok, new_max}
    assert IdParser.call(to_string(new_max + 1), max: new_max) == {:error, :out_of_range}
  end
end
