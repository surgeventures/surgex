defmodule Surgex.ParseusTest do
  use ExUnit.Case
  import Surgex.Parseus
  alias Surgex.Parseus.Error

  @long_text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor " <>
    "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud" <>
    "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor" <>
    "in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur" <>
    "sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id " <>
    "est laborum."

  test "basic success" do
    input = %{
      "name" => "Mike",
      "email" => "mike@example.com",
      "type" => "admin",
      "license-agreement" => "1",
      "age" => "21",
      "birth-date" => "1950-02-15",
      "notes" => "Please don't send me e-mails!",
    }

    assert %{output: output, errors: []} = parse_basic(input)
    assert sort(output) == [
      age: 21,
      birth_date: ~D[1950-02-15],
      email: "mike@example.com",
      name: "Mike",
      notes: "Please don't send me e-mails!",
      type: :admin,
    ]
  end

  test "basic failure" do
    input = %{
      "email" => "mike",
      "type" => "something-else",
      "license-agreement" => "0",
      "extra-field" => "abc",
      "age" => "14",
      "birth-date" => "123",
      "notes" => @long_text,
    }

    assert set = %{output: output, errors: errors} = parse_basic(input)
    assert sort(output) == []
    assert sort(errors) == [
      age: %Error{
        source: :number_validator,
        reason: :not_greater_than_or_equal_to,
        info: [min_or_eq: 18]
      },
      agreement: %Error{source: :acceptance_validator},
      birth_date: %Error{source: :date_parser},
      email: %Error{source: :format_validator, info: [format: ~r/^.*@example\.com$/]},
      name: %Error{source: :required_validator},
      notes: %Error{source: :exclusion_validator, info: [forbidden_values: [@long_text]]},
      notes: %Error{source: :length_validator, reason: :above_max, info: [max: 100]},
      type: %Error{source: :enum_parser}
    ]

    assert get_input_key(set, :agreement) == "license-agreement"
  end

  test "nested success" do
    input = %{
      data: %{
        type: "users",
        id: 1,
        attributes: %{
          "name" => "Mike"
        },
        relationships: %{
          "avatar" => %{
            data: %{
              type: "user-avatars",
              id: 2,
              attributes: %{
                "url" => "http://example.com/avatar.jpg"
              }
            }
          },
          "accounts" => %{
            data: [
              %{
                type: "user-accounts",
                attributes: %{
                  "provider" => "facebook",
                  "uid" => 300
                }
              },
              %{
                type: "user-accounts",
                attributes: %{
                  "provider" => "twitter",
                  "uid" => 400
                }
              }
            ]
          }
        }
      }
    }

    assert %{output: output, errors: []} = parse_nested(input)
    assert sort(output) == [
      accounts: [
        [provider: "facebook", uid: 300],
        [provider: "twitter", uid: 400],
      ],
      avatar: [
        id: 2,
        url: "http://example.com/avatar.jpg",
      ],
      id: 1,
      name: "Mike",
    ]
    assert get_in(output[:accounts], [Access.all(), :uid]) == [300, 400]
  end

  test "nested failure" do
    input = %{
      data: %{
        id: -1,
        attributes: %{
          "name" => @long_text
        },
      }
    }

    assert set = %{output: output, errors: errors} = parse_nested(input)
    assert sort(output) == []
    assert sort(errors) == [
      id: %Error{source: :number_validator, reason: :not_greater_than, info: [min: 0]},
      name: %Error{source: :length_validator, reason: :above_max, info: [max: 50]},
    ]
    assert get_input_key(set, :id) == [:data, :id]
    assert get_input_key(set, :name) == [:data, :attributes, "name"]
  end

  defp parse_basic(input) do
    input
    |> cast(["name", "email", "type", "license-agreement", "age", "birth-date", "notes"])
    |> rename(:license_agreement, :agreement)
    |> validate_required([:name, :email, :type, :agreement])
    |> validate_length(:name, max: 50)
    |> validate_format(:email, ~r/^.*@example\.com$/)
    |> validate_length(:email, max: 100)
    |> parse_enum(:type, ["regular", "admin", "super-admin"])
    |> validate_inclusion(:type, [:regular, :admin])
    |> parse_boolean(:agreement)
    |> validate_boolean(:agreement)
    |> validate_acceptance(:agreement)
    |> drop(:agreement)
    |> parse_integer(:age)
    |> validate_number(:age, type: :integer, greater_than_or_equal_to: 18, less_than: 123)
    |> parse_date(:birth_date)
    |> validate_length(:notes, max: 100)
    |> validate_exclusion(:notes, [@long_text])
    |> drop_invalid()
  end

  defp parse_nested(input) do
    input
    |> cast_in(:data, &parse_nested_data/1)
    |> drop_invalid()
  end

  defp parse_nested_data(input) do
    input
    |> cast([:id, :type])
    |> validate_required([:id])
    |> validate_number(:id, greater_than: 0)
    |> validate_inclusion(:type, ["users"])
    |> drop(:type)
    |> cast_in(:attributes, &parse_nested_attrs/1)
    |> cast_in([:relationships, "avatar", :data], :avatar, &parse_nested_avatar/1)
    |> cast_all_in([:relationships, "accounts", :data, Access.all()], :accounts,
         &parse_nested_account/1)
  end

  defp parse_nested_attrs(input) do
    input
    |> cast(["name"])
    |> validate_length(:name, max: 50)
  end

  defp parse_nested_avatar(input) do
    input
    |> cast([:id, :type])
    |> validate_required([:id])
    |> validate_number(:id, greater_than: 0)
    |> validate_inclusion(:type, ["user-avatars"])
    |> drop(:type)
    |> cast_in(:attributes, &parse_nested_avatar_attrs/1)
  end

  defp parse_nested_avatar_attrs(input) do
    input
    |> cast(["url"])
    |> validate_length(:url, max: 50)
  end

  defp parse_nested_account(input) do
    input
    |> cast([:type])
    |> validate_inclusion(:type, ["user-accounts"])
    |> drop(:type)
    |> cast_in(:attributes, &parse_nested_account_attrs/1)
  end

  defp parse_nested_account_attrs(input) do
    input
    |> cast(["provider", "uid"])
    |> validate_required(:provider)
    |> validate_inclusion(:provider, ["facebook", "twitter"])
    |> validate_number(:uid)
  end

  def sort(struct = %{__struct__: _}), do: struct
  def sort(enum) when is_list(enum) or is_map(enum) do
    enum
    |> Enum.sort
    |> Enum.map(fn
         {key, value} -> {key, sort(value)}
         value -> sort(value)
       end)
  end
  def sort(any), do: any
end
