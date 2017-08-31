defmodule Surgex.ParseusTest do
  use ExUnit.Case
  alias Surgex.Parseus
  alias Surgex.Parseus.Error

  @long_text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor " <>
    "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud" <>
    "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor" <>
    "in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur" <>
    "sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id " <>
    "est laborum."

  test "basic success" do
    import Parseus

    input = %{
      "name" => "Mike",
      "email" => "mike@example.com",
      "type" => "admin",
      "license-agreement" => "1",
      "age" => "21",
      "birth-date" => "1950-02-15",
      "notes" => "Please don't send me e-mails!",
    }

    assert %{output: output, errors: []} =
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
      |> validate_exclusion(:type, [@long_text])
      |> drop_invalid()

    assert Enum.sort(output) == [
      age: 21,
      birth_date: ~D[1950-02-15],
      email: "mike@example.com",
      name: "Mike",
      notes: "Please don't send me e-mails!",
      type: :admin,
    ]
  end

  test "basic failure" do
    import Parseus

    input = %{
      "email" => "mike",
      "type" => "something-else",
      "license-agreement" => "0",
      "extra-field" => "abc",
      "age" => "14",
      "birth-date" => "123",
      "notes" => @long_text,
    }

    assert px = %{output: output, errors: errors} =
      input
      |> cast(["name", "email", "type", "license-agreement", "age", "birth-date", "notes"])
      |> rename(:license_agreement, :agreement)
      |> validate_required([:name, :email, :type, :agreement])
      |> validate_length(:name, max: 50)
      |> validate_format(:email, ~r/^.*@example\.com$/)
      |> validate_length(:email, max: 100)
      |> add_error(:email, :taken)
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

    assert Enum.sort(output) == []
    assert Enum.sort(errors) == [
      age: %Error{
        source: :number_validator,
        reason: :not_greater_than_or_equal_to,
        info: [min_or_eq: 18]
      },
      agreement: %Error{source: :acceptance_validator},
      birth_date: %Error{source: :date_parser},
      email: %Error{reason: :taken},
      email: %Error{source: :format_validator, info: [format: ~r/^.*@example\.com$/]},
      name: %Error{source: :required_validator},
      notes: %Error{source: :exclusion_validator, info: [forbidden_values: [@long_text]]},
      notes: %Error{source: :length_validator, reason: :above_max, info: [max: 100]},
      type: %Error{source: :enum_parser}
    ]

    assert "license-agreement" ==
      get_input_key(px, :agreement)
  end
end
