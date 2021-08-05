defmodule Surgex.Parser.ResourceParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ResourceParser

  test "nil" do
    assert ResourceParser.call(nil, fn _ -> nil end) == {:ok, nil}
  end

  test "valid input" do
    assert ResourceParser.call(%{id: "123"}, fn resource ->
             assert %{id: id} = resource

             {:ok, [id: id]}
           end) == {:ok, [id: "123"]}
  end

  test "invalid input" do
    assert ResourceParser.call(%{id: "123"}, fn resource ->
             assert %{id: _} = resource

             {:error, :invalid_pointers, [id: "id"]}
           end) == {:error, [id: "id"]}
  end

  test "non-map input" do
    assert ResourceParser.call(5, & to_string(&1)) == {:error, :invalid_resource}
  end
end
