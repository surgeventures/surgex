defmodule Surgex.Parser.ResourceArrayParserTest do
  use ExUnit.Case
  alias Surgex.Parser.ResourceArrayParser

  test "nil" do
    assert ResourceArrayParser.call(nil, fn _ -> nil end) == {:ok, nil}
  end

  test "valid input" do
    assert ResourceArrayParser.call(
             [%{id: "123"}, %{id: "456"}],
             fn resource ->
               assert %{id: id} = resource

               {:ok, [id: id]}
             end,
             min: 1,
             max: 2
           ) == {:ok, [[id: "123"], [id: "456"]]}
  end

  test "invalid input" do
    assert ResourceArrayParser.call([%{id: "123"}, %{id: "456"}], fn resource ->
             assert %{id: _} = resource

             {:error, :invalid_pointers, [id: "id"]}
           end) == {:error, [id: "0/id", id: "1/id"]}
  end

  test "min out of range" do
    assert ResourceArrayParser.call([%{id: "123"}], fn _ -> nil end, min: 2) == {:error, :too_short}
  end

  test "max out of range" do
    assert ResourceArrayParser.call([%{id: "123"}, %{id: "456"}], fn _ -> nil end, max: 1) ==
             {:error, :too_long}
  end

  test "min and max present, array too short" do
    assert ResourceArrayParser.call([%{id: "123"}, %{id: "456"}], fn _ -> nil end, min: 3, max: 4) ==
             {:error, :too_short}
  end

  test "min and max present, array too long" do
    assert ResourceArrayParser.call(
             [%{id: "123"}, %{id: "456"}, %{id: "789"}],
             fn _ -> nil end,
             min: 1,
             max: 2
           ) == {:error, :too_long}
  end
end
