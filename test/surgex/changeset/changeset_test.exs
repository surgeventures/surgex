defmodule Surgex.ChangesetTest do
  use ExUnit.Case
  alias Surgex.Changeset

  test "changeset with all possible errors" do
    assert Changeset.build_errors_document(%{
             errors: [
               taken_field: {"has already been taken", nil},
               required_field: {nil, [validation: :required]},
               invalid_field: {nil, nil},
               invalid_type_field: {nil, [validation: :type]}
             ]
           }) == %Jabbax.Document{
             errors: [
               %Jabbax.Document.Error{
                 code: "taken",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/taken_field"}
               },
               %Jabbax.Document.Error{
                 code: "required",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/required_field"}
               },
               %Jabbax.Document.Error{
                 code: "invalid",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/invalid_field"}
               },
               %Jabbax.Document.Error{
                 code: "invalid_type",
                 source: %Jabbax.Document.ErrorSource{
                   pointer: "/data/attributes/invalid_type_field"
                 }
               }
             ]
           }
  end
end
