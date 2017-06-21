defmodule Surgex.Parser.IncludeParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IncludeParser

  test "nil" do
    assert IncludeParser.call(nil, [:user]) == {:ok, []}
  end

  test "valid input" do
    assert IncludeParser.call("", [:user]) == {:ok, []}
    assert IncludeParser.call("user", [:user]) == {:ok, [:user]}
  end

  test "invalid input" do
    assert IncludeParser.call("other", [:user]) == {:error, :invalid_relationship_path}
  end
end
