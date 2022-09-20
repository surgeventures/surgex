defmodule Surgex.Parser.SlugOrIdParserTest do
  use ExUnit.Case
  alias Surgex.Parser.SlugOrIdParser

  test "nil" do
    assert SlugOrIdParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert SlugOrIdParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert SlugOrIdParser.call("abc-123") == {:ok, "abc-123"}
    assert SlugOrIdParser.call("123") == {:ok, 123}
  end

  test "invalid input" do
    assert SlugOrIdParser.call("0") == {:error, :invalid_identifier}
    assert SlugOrIdParser.call("abc_123") == {:error, :invalid_slug}
    assert SlugOrIdParser.call("abć-123") == {:error, :invalid_slug}
    assert SlugOrIdParser.call("abć%20123") == {:error, :invalid_slug}
  end

  test "unsupported input type" do
    assert SlugOrIdParser.call(0.3) == {:error, :invalid_slug}
    assert SlugOrIdParser.call(["123"]) == {:error, :invalid_slug}
  end

  test "forwards options to id parser" do
    assert SlugOrIdParser.call("123", max: 123) == {:ok, 123}
    assert SlugOrIdParser.call("123", max: 122) == {:error, :invalid_identifier}
  end
end
