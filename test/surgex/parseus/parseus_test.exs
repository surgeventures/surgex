defmodule Surgex.ParseusTest do
  use ExUnit.Case

  test "basic successful parsing" do
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
      |> rename_key(:license_agreement, :agreement)
      |> validate_required([:name, :email, :type, :agreement])
      |> validate_length(:name, max: 50)
      |> validate_format(:email, ~r/^.*@example\.com$/)
      |> validate_length(:email, max: 100)
      |> parse_enum(:type, ["regular", "admin", "super-admin"])
      |> validate_inclusion(:type, [:regular, :admin])
      |> parse_boolean(:agreement)
      |> validate_acceptance(:agreement)
      |> drop_key(:agreement)
      |> parse_integer(:age)
      |> validate_number(:age, type: :integer, greater_than_or_equal_to: 18, less_than: 123)
      |> validate_length(:notes, max: 100)

    assert Enum.sort(output) == [
      age: 21,
      email: "mike@example.com",
      name: "Mike",
      notes: "Please don't send me e-mails!",
      type: :admin,
    ]
  end
end
