defmodule Surgex.Parser.StringParserTest do
  use ExUnit.Case
  alias Surgex.Parser.StringParser

  test "nil" do
    assert StringParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert StringParser.call("") == {:ok, nil}
    assert StringParser.call("abc") == {:ok, "abc"}
    assert StringParser.call("  abc  ") == {:ok, "  abc  "}
  end

  test "min" do
    opt = [min: 4]
    assert StringParser.call(nil, opt) == {:ok, nil}
    assert StringParser.call("", opt) == {:error, :too_short}
    assert StringParser.call("abc", opt) == {:error, :too_short}
    assert StringParser.call("abcd", opt) == {:ok, "abcd"}
    assert StringParser.call("  abcd  ", opt) == {:ok, "  abcd  "}
    assert StringParser.call("abcde", opt) == {:ok, "abcde"}
  end

  test "max" do
    opt = [max: 4]
    assert StringParser.call(nil, opt) == {:ok, nil}
    assert StringParser.call("", opt) == {:ok, nil}
    assert StringParser.call("abc", opt) == {:ok, "abc"}
    assert StringParser.call("abcd", opt) == {:ok, "abcd"}
    assert StringParser.call("abcde", opt) == {:error, :too_long}
  end

  test "trim" do
    opt = [trim: true]
    assert StringParser.call(nil, opt) == {:ok, nil}
    assert StringParser.call("", opt) == {:ok, nil}
    assert StringParser.call("abc", opt) == {:ok, "abc"}
    assert StringParser.call("\t\n  abc\t  \n", opt) == {:ok, "abc"}
  end

  test "trim priority over min and max" do
    opt = [min: 3, max: 4, trim: true]
    assert StringParser.call("  ab  ", opt) == {:error, :too_short}
    assert StringParser.call("  abc  ", opt) == {:ok, "abc"}
    assert StringParser.call("  abcde  ", opt) == {:error, :too_long}
  end

  test "regex" do
    opt = [regex: ~r/^[a-h]{1,4}$/]
    assert StringParser.call("abc", opt) == {:ok, "abc"}
    assert StringParser.call("axn", opt) == {:error, :bad_format}
    assert StringParser.call("abcde", opt) == {:error, :bad_format}
  end

  test "regex check is done after trimming" do
    opt = [regex: ~r/^[a-h]{1,4}$/, trim: true]
    assert StringParser.call("  abc ", opt) == {:ok, "abc"}
  end

  test "unsupported input type" do
    assert StringParser.call(1.4) == {:error, :invalid_string}
  end
end
