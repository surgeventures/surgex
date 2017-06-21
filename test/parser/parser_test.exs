defmodule Surgex.ParserTest do
  use ExUnit.Case
  alias Surgex.Parser
  alias Surgex.Parser.{
    IntegerParser,
    RequiredParser,
    StringParser,
  }

  @parsers [
    id: [&IntegerParser.call/1, &RequiredParser.call/1],
    first_name: [&StringParser.call/1, &RequiredParser.call/1],
    last_name: &StringParser.call/1
  ]

  @valid_params %{
    "id" => "123",
    "first-name" => "Jack",
    "last-name" => ""
  }

  @invalid_params %{
    "id" => "abc",
    "first-name" => "",
    "other-param" => "x"
  }

  describe "parse/2" do
    test "valid params" do
      parser_output = Parser.parse @valid_params, @parsers

      assert parser_output == {:ok, [
        first_name: "Jack",
        id: 123,
      ]}
    end

    test "invalid params" do
      parser_output = Parser.parse @invalid_params, @parsers

      assert parser_output == {:error, :invalid_parameters, [
        required: "first-name",
        invalid_integer: "id",
        unknown: "other-param",
      ]}
    end
  end

  describe "flat_parse/2" do
    test "valid params" do
      parser_output = Parser.flat_parse @valid_params, @parsers

      assert parser_output == {:ok, 123, "Jack", nil}
    end

    test "invalid params" do
      parser_output = Parser.flat_parse @invalid_params, @parsers

      assert parser_output == {:error, :invalid_parameters, [
        required: "first-name",
        invalid_integer: "id",
        unknown: "other-param",
      ]}
    end
  end

  describe "assert_blank_params/1" do
    test "valid params" do
      parser_output = Parser.assert_blank_params %{}

      assert parser_output == :ok
    end

    test "invalid params" do
      parser_output = Parser.assert_blank_params %{
        "some-param" => nil,
        "other-param" => "x"
      }

      assert parser_output == {:error, :invalid_parameters, [
        unknown: "other-param",
        unknown: "some-param",
      ]}
    end
  end

  describe "map_parsed_options/2" do
    test "valid output" do
      parser_output = {:ok, [
        first_name: "Jack",
        id: 123,
      ]}

      mapped_output = Parser.map_parsed_options(parser_output, [
        id: :user_id,
        other: :another,
      ])

      assert mapped_output == {:ok, [
        user_id: 123,
        first_name: "Jack",
      ]}
    end

    test "invalid output" do
      parser_output = {:error, :invalid_parameters}

      mapped_output = Parser.map_parsed_options(parser_output, [
        id: :user_id,
        other: :another,
      ])

      assert mapped_output == {:error, :invalid_parameters}
    end
  end
end
