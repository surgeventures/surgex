defmodule Surgex.Parser.ResourceArrayParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ResourceArrayParser

  test "nil" do
    assert ResourceArrayParser.call(nil, fn _ -> nil end) == {:ok, nil}
  end

  test "valid input" do
    assert ResourceArrayParser.call([%{id: "123"}, %{id: "456"}], fn resource ->
      assert %{id: id} = resource

      {:ok, [id: id]}
    end) == {:ok, [[id: "123"], [id: "456"]]}
  end

  test "invalid input" do
    assert ResourceArrayParser.call([%{id: "123"}, %{id: "456"}], fn resource ->
      assert %{id: _} = resource

      {:error, :invalid_pointers, [id: "id"]}
    end) == {:error, [id: "0/id", id: "1/id"]}
  end
end
