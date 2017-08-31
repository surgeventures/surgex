defmodule Surgex.ParseusTest do
  use ExUnit.Case

  test "basic success" do
    import Surgex.Parseus

    input = %{
      "name" => "Mike",
      "email" => "mike@example.com",
      "type" => "admin",
      "license-agreement" => "1",
      "age" => "21",
      "notes" => "Please don't send me e-mails!",
    }

    assert %{output: output, errors: []} =
      input
      |> cast(["name", "email", "type", "license-agreement", "age", "notes"])
      |> rename(:license_agreement, :agreement)
      |> validate_required([:name, :email, :type, :agreement])
      |> validate_length(:name, max: 50)
      |> validate_format(:email, ~r/^.*@example\.com$/)
      |> validate_length(:email, max: 100)
      |> parse_enum(:type, ["regular", "admin", "super-admin"])
      |> validate_inclusion(:type, [:regular, :admin])
      |> parse_boolean(:agreement)
      |> validate_acceptance(:agreement)
      |> drop(:agreement)
      |> parse_integer(:age)
      |> validate_number(:age, type: :integer, greater_than_or_equal_to: 18, less_than: 123)
      |> validate_length(:notes, max: 100)
      |> drop_invalid()

    assert Enum.sort(output) == [
      age: 21,
      email: "mike@example.com",
      name: "Mike",
      notes: "Please don't send me e-mails!",
      type: :admin,
    ]
  end

  test "basic failure" do
    import Surgex.Parseus

    input = %{
      "email" => "mike",
      "type" => "something-else",
      "license-agreement" => "0",
      "extra-field" => "abc",
      "age" => "14",
      "notes" => (1..110 |> Enum.map(fn _ -> "t" end) |> Enum.join),
    }

    assert %{output: output, errors: errors} =
      input
      |> cast(["name", "email", "type", "license-agreement", "age", "notes"])
      |> rename(:license_agreement, :agreement)
      |> validate_required([:name, :email, :type, :agreement])
      |> validate_length(:name, max: 50)
      |> validate_format(:email, ~r/^.*@example\.com$/)
      |> validate_length(:email, max: 100)
      |> parse_enum(:type, ["regular", "admin", "super-admin"])
      |> validate_inclusion(:type, [:regular, :admin])
      |> parse_boolean(:agreement)
      |> validate_acceptance(:agreement)
      |> drop(:agreement)
      |> parse_integer(:age)
      |> validate_number(:age, type: :integer, greater_than_or_equal_to: 18, less_than: 123)
      |> validate_length(:notes, max: 100)
      |> drop_invalid()

    assert Enum.sort(output) == []
    assert Enum.sort(errors) == [
      age: %Surgex.Parseus.Error{reason: :not_greater_than_or_equal_to, source: :number_validator},
      agreement: %Surgex.Parseus.Error{source: :acceptance_validator},
      email: %Surgex.Parseus.Error{source: :format_validator},
      name: %Surgex.Parseus.Error{source: :required_validator},
      notes: %Surgex.Parseus.Error{reason: :not_within_min, source: :length_validator},
      type: %Surgex.Parseus.Error{source: :enum_parser}
    ]
  end
end
