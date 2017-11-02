defmodule Surgex.ParserTest do
  use ExUnit.Case
  use Jabbax.Document
  alias Surgex.Parser
  alias Surgex.Parser.RequiredParser

  @param_parsers [
    id: [:integer, :required],
    uuid: [:string, :required],
    price: [:float, :required],
    first_name: [:string, &RequiredParser.call/1],
    last_name: :string,
    phone: :string,
    include: [{:include, [:comments]}, :required],
    address: [{:string, :allow_empty}]
  ]

  @valid_params %{
    "id" => "123",
    "uuid" => "asdf",
    "price" => "10.5",
    "first-name" => "Jack",
    "last-name" => "",
    "include" => "comments",
    "address" => ""
  }

  @invalid_params %{
    "id" => "abc",
    "price" => "qwerty",
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
        address: "",
        include: [:comments],
        last_name: nil,
        first_name: "Jack",
        price: 10.5,
        uuid: "asdf",
        id: 123,
      ]}
    end

    test "invalid params" do
      parser_output = Parser.parse @invalid_params, @param_parsers

      assert parser_output == {:error, :invalid_parameters, [
        invalid_relationship_path: "include",
        required: "first-name",
        invalid_float: "price",
        required: "uuid",
        invalid_integer: "id",
        unknown: "other-param",
      ]}
    end

    test "valid doc" do
      parser_output = Parser.parse @valid_doc, @doc_parsers

      assert parser_output == {:ok, [
        avatar: 456,
        last_name: nil,
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
        last_name: nil,
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

    test "valid doc with nested resource" do
      doc = put_in @valid_doc.data.relationships["image"],
        %Resource{id: "1", attributes: %{"name" => "image-name"}}
      nested_parser = fn resource ->
        Parser.parse resource,
          id: [:id, :required],
          attributes: %{
            name: [:string, :required]
          }
      end

      parsers = put_in @doc_parsers[:relationships][:image],
        [{:resource, nested_parser}, :required]

      parser_output = Parser.parse doc, parsers

      assert parser_output == {:ok, [
        image: [name: "image-name", id: 1],
        avatar: 456,
        last_name: nil,
        first_name: "Jack",
        id: 123
      ]}
    end

    test "invalid doc with nested resource" do
      doc = put_in @valid_doc.data.relationships["image"],
        %Resource{id: "abc", attributes: %{"name" => ""}}
      nested_parser = fn resource ->
        Parser.parse resource,
          id: [:id, :required],
          attributes: %{
            name: [:string, :required]
          }
      end

      parsers = put_in @doc_parsers[:relationships][:image],
        [{:resource, nested_parser}, :required]

      parser_output = Parser.parse doc, parsers
      assert parser_output == {:error, :invalid_pointers, [
        invalid_integer: "/data/relationships/image/id",
        required: "/data/relationships/image/attributes/name"
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

      assert parser_output == {:ok, 123, "asdf", 10.5, "Jack", nil, nil, [:comments], ""}
    end

    test "invalid params" do
      parser_output = Parser.flat_parse @invalid_params, @param_parsers

      assert parser_output == {:error, :invalid_parameters, [
        invalid_relationship_path: "include",
        required: "first-name",
        invalid_float: "price",
        required: "uuid",
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
