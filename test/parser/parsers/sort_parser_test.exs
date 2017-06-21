defmodule Surgex.Parser.SortParserTest do
  use ExUnit.Case
  alias Surgex.Parser.SortParser

  test "nil" do
    assert SortParser.call(nil, [:id, :name]) == {:ok, nil}
  end

  test "valid input" do
    assert SortParser.call("id", [:id, :name]) == {:ok, {:asc, :id}}
    assert SortParser.call("-id", [:id, :name]) == {:ok, {:desc, :id}}
  end

  test "invalid input" do
    assert SortParser.call("other", [:id, :name]) == {:error, :invalid_sort_column}
  end
end
