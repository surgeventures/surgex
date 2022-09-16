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

  @int8_max 9_223_372_036_854_775_807
  @int4_max 2_147_483_647

  test "parses max and validates if valid numeric id type or integer" do
    assert IdParser.call(to_string(@int4_max), max: @int4_max) == {:ok, @int4_max}

    assert IdParser.call(to_string(@int4_max), max: :integer) == {:ok, @int4_max}
    assert IdParser.call(to_string(@int4_max), max: :int) == {:ok, @int4_max}
    assert IdParser.call(to_string(@int4_max), max: :serial) == {:ok, @int4_max}

    assert IdParser.call(to_string(@int8_max), max: :biginteger) == {:ok, @int8_max}
    assert IdParser.call(to_string(@int8_max), max: :bigint) == {:ok, @int8_max}
    assert IdParser.call(to_string(@int8_max), max: :bigserial) == {:ok, @int8_max}

    assert IdParser.call(to_string(@int4_max + 1), max: @int4_max) == {:error, :out_of_range}
    assert IdParser.call(to_string(@int4_max + 1), max: :integer) == {:error, :out_of_range}
  end

  test "handles invalid max" do
    assert IdParser.call("1", max: "invalid") == {:error, :invalid_max}
  end
end
