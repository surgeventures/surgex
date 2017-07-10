defmodule Surgex.ParserTest do
  use ExUnit.Case
  use Jabbax.Document
  alias Surgex.Parser
  alias Surgex.Parser.RequiredParser

  @param_parsers [
    id: [:integer, :required],
    first_name: [:string, &RequiredParser.call/1],
    last_name: :string,
    include: [{:include, [:comments]}, :required]
  ]

  @valid_params %{
    "id" => "123",
    "first-name" => "Jack",
    "last-name" => "",
    "include" => "comments"
  }

  @invalid_params %{
    "id" => "abc",
    "first-name" => "",
    "other-param" => "x",
    "include" => "invalid"
  }

  @doc_parsers [
    id: [:integer, :required],
    attributes: %{
      first_name: [:string, &RequiredParser.call/1],
      last_name: :string
    },
    relationships: %{
      avatar: :resource_id
    }
  ]

  @valid_doc %Document{
    data: %Resource{
      id: "123",
      attributes: %{
        "first-name" => "Jack",
        "last-name" => ""
      },
      relationships: %{
        "avatar" => %ResourceId{
          id: "456"
        }
      }
    }
  }

  @invalid_doc %Document{
    data: %Resource{
      id: "abc",
      attributes: %{
        "first-name" => "",
        "other-param" => "x"
      },
      relationships: %{
        "avatar" => %ResourceId{
          id: "def"
        },
        "other-rel" => %ResourceId{
          id: "456"
        },
      }
    }
  }

  @malformed_doc %Document{}

  describe "parse/2" do
    test "valid params" do
      parser_output = Parser.parse @valid_params, @param_parsers

      assert parser_output == {:ok, [
        include: [:comments],
        first_name: "Jack",
        id: 123,
      ]}
    end

    test "valid params, drop_nil: false" do
      parser_output = Parser.parse @valid_params, @param_parsers, drop_nil: false

      assert parser_output == {:ok, [
        include: [:comments],
        last_name: nil,
        first_name: "Jack",
        id: 123,
      ]}
    end

    test "invalid params" do
      parser_output = Parser.parse @invalid_params, @param_parsers

      assert parser_output == {:error, :invalid_parameters, [
        invalid_relationship_path: "include",
        required: "first-name",
        invalid_integer: "id",
        unknown: "other-param",
      ]}
    end

    test "valid doc" do
      parser_output = Parser.parse @valid_doc, @doc_parsers

      assert parser_output == {:ok, [
        avatar: 456,
        first_name: "Jack",
        id: 123,
      ]}
    end

    test "invalid doc" do
      parser_output = Parser.parse @invalid_doc, @doc_parsers

      assert parser_output == {:error, :invalid_pointers, [
        invalid_integer: "/data/id",
        required: "/data/attributes/first-name",
        unknown: "/data/attributes/other-param",
        invalid_integer: "/data/relationships/avatar/id",
        unknown: "/data/relationships/other-rel"
      ]}
    end

    test "malformed doc" do
      parser_output = Parser.parse @malformed_doc, @doc_parsers

      assert parser_output == {:error, :invalid_pointers, [required: "/data"]}
    end

    test "valid doc with nested resource array" do
      doc = put_in @valid_doc.data.relationships["image-array"], [
        %Resource{id: "1"},
        %Resource{id: "2"},
      ]

      nested_parser = fn resource ->
        Parser.parse resource, id: [:id, :required]
      end

      parsers = put_in @doc_parsers[:relationships][:image_array],
        [{:resource_array, nested_parser}, :required]

      parser_output = Parser.parse doc, parsers

      assert parser_output == {:ok, [
        image_array: [[id: 1], [id: 2]],
        avatar: 456,
        first_name: "Jack",
        id: 123
      ]}
    end

    test "invalid doc with nested resource array" do
      doc = put_in @valid_doc.data.relationships["image-array"], [
        %Resource{id: "abc"},
        %Resource{id: "2"},
      ]

      nested_parser = fn resource ->
        Parser.parse resource, id: [:id, :required]
      end

      parsers = put_in @doc_parsers[:relationships][:image_array],
        [{:resource_array, nested_parser}, :required]

      parser_output = Parser.parse doc, parsers

      assert parser_output == {:error, :invalid_pointers, [
        invalid_integer: "/data/relationships/image-array/0/id"
      ]}
    end

    test "nil input" do
      parser_output = Parser.parse nil, []

      assert parser_output == {:error, :empty_input}
    end
  end

  describe "flat_parse/2" do
    test "valid params" do
      parser_output = Parser.flat_parse @valid_params, @param_parsers

      assert parser_output == {:ok, 123, "Jack", nil, [:comments]}
    end

    test "invalid params" do
      parser_output = Parser.flat_parse @invalid_params, @param_parsers

      assert parser_output == {:error, :invalid_parameters, [
        invalid_relationship_path: "include",
        required: "first-name",
        invalid_integer: "id",
        unknown: "other-param",
      ]}
    end

    test "valid doc" do
      parser_output = Parser.flat_parse @valid_doc, @doc_parsers

      assert parser_output == {:ok, 123, "Jack", nil, 456}
    end

    test "malformed doc" do
      parser_output = Parser.flat_parse @malformed_doc, @doc_parsers

      assert parser_output == {:error, :invalid_pointers, [required: "/data"]}
    end

    test "nil input" do
      parser_output = Parser.flat_parse nil, []

      assert parser_output == {:error, :empty_input}
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
