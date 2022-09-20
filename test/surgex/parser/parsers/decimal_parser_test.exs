defmodule Surgex.Parser.DecimalParserTest do
  use ExUnit.Case
  alias Surgex.Parser.DecimalParser

  test "nil" do
    assert DecimalParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert DecimalParser.call("") == {:ok, nil}
  end

  test "valid input" do
    assert DecimalParser.call(123) == {:ok, Decimal.new("123")}
    assert DecimalParser.call("123") == {:ok, Decimal.new("123")}
    assert DecimalParser.call("123", min: 123, max: 123) == {:ok, Decimal.new("123")}
    assert DecimalParser.call("123.0") == {:ok, Decimal.new("123.0")}
  end

  test "invalid input" do
    assert DecimalParser.call("123abc") == {:error, :invalid_decimal}
    assert DecimalParser.call("?") == {:error, :invalid_decimal}
    assert DecimalParser.call("1", min: 2) == {:error, :out_of_range}
    assert DecimalParser.call("1", max: 0) == {:error, :out_of_range}
  end

  test "unsupported input type" do
    assert DecimalParser.call(0.5) == {:error, :invalid_decimal}
    assert DecimalParser.call([1]) == {:error, :invalid_decimal}
    assert DecimalParser.call(%{test: 1}) == {:error, :invalid_decimal}
  end

  test "valid range input" do
    assert DecimalParser.call(1, min: 0, max: 10) == {:ok, Decimal.new("1")}
    assert DecimalParser.call(1, min: 0) == {:ok, Decimal.new("1")}
    assert DecimalParser.call(1, max: 10) == {:ok, Decimal.new("1")}
  end

  test "invalid range input" do
    assert DecimalParser.call(1, min: 10, max: 100) == {:error, :out_of_range}
    assert DecimalParser.call(1, min: 10) == {:error, :out_of_range}
    assert DecimalParser.call(10, max: 1) == {:error, :out_of_range}
  end
end
