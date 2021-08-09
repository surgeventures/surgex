defmodule Surgex.Parser.SlugParserTest do
  use ExUnit.Case
  alias Surgex.Parser.SlugParser

  test "nil" do
    assert SlugParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert SlugParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert SlugParser.call("abc-123") == {:ok, "abc-123"}
  end

  test "invalid input" do
    assert SlugParser.call("abc_123") == {:error, :invalid_slug}
    assert SlugParser.call("abć-123") == {:error, :invalid_slug}
    assert SlugParser.call("abć%20123") == {:error, :invalid_slug}
  end

  test "unsupported input type" do
    assert SlugParser.call(1.33) == {:error, :invalid_slug}
    assert SlugParser.call(["abc-123"]) == {:error, :invalid_slug}
  end
end
