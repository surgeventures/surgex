defmodule Surgex.Parser.SortParserTest do
  use ExUnit.Case
  alias Surgex.Parser.SortParser

  describe "call/2" do
    test "nil" do
      assert SortParser.call(nil, [:id, :name]) == {:ok, nil}
    end

    test "empty string" do
      assert SortParser.call("", [:id, :name]) == {:ok, nil}
    end

    test "valid input" do
      assert SortParser.call("id", [:id, :name]) == {:ok, {:asc, :id}}
      assert SortParser.call("first-name", [:id, :first_name]) == {:ok, {:asc, :first_name}}
      assert SortParser.call("-id", [:id, :name]) == {:ok, {:desc, :id}}
    end

    test "invalid input" do
      assert SortParser.call("other", [:id, :name]) == {:error, :invalid_sort_column}
    end
  end

  describe "flatten/2" do
    test "valid input" do
      assert SortParser.flatten({:ok, sort: {:asc, :col}}, :sort) ==
               {:ok, sort_by: :col, sort_direction: :asc}
    end

    test "invalid input" do
      assert SortParser.flatten({:error, :test}, :sort) == {:error, :test}
      assert SortParser.flatten({:error, :test, nil}, :sort) == {:error, :test, nil}
    end
  end
end
