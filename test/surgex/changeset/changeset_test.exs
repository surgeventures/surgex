defmodule Surgex.ChangesetTest do
  use ExUnit.Case
  alias Surgex.Changeset

  import Ecto.Changeset, only: [change: 2, add_error: 3, add_error: 4]

  defmodule TestSchema do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:name, :string)

      embeds_one :address, TestAddress do
        field(:city, :string)
        field(:street, :string)

        embeds_one :country, TestCountry do
          field(:code, :string)
        end
      end
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:name])
      |> cast_embed(:address, with: &address_changeset/2)
    end

    defp address_changeset(schema, params) do
      schema
      |> cast(params, [:city, :street])
      |> validate_required([:city])
      |> cast_embed(:country, with: &country_changeset/2)
    end

    defp country_changeset(schema, params) do
      schema
      |> cast(params, [:code])
      |> validate_inclusion(:code, ["us", "ca", "pl"])
    end
  end

  test "changeset with all possible errors" do
    changeset =
      %TestSchema{}
      |> change(%{})
      |> add_error(:taken_field, "has already been taken")
      |> add_error(:required_field, "", validation: :required)
      |> add_error(:invalid_type_field, "", validation: :type)
      |> add_error(:invalid_field, "")

    assert Changeset.build_errors_document(changeset) == %Jabbax.Document{
             errors: [
               %Jabbax.Document.Error{
                 code: "invalid",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/invalid_field"}
               },
               %Jabbax.Document.Error{
                 code: "invalid_type",
                 source: %Jabbax.Document.ErrorSource{
                   pointer: "/data/attributes/invalid_type_field"
                 }
               },
               %Jabbax.Document.Error{
                 code: "required",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/required_field"}
               },
               %Jabbax.Document.Error{
                 code: "taken",
                 source: %Jabbax.Document.ErrorSource{pointer: "/data/attributes/taken_field"}
               }
             ]
           }
  end

  test "changeset with nested errors" do
    changeset =
      TestSchema.changeset(%TestSchema{}, %{
        name: "test",
        address: %{street: "Main", country: %{code: "es"}}
      })

    assert Changeset.build_errors_document(changeset) == %Jabbax.Document{
             errors: [
               %Jabbax.Document.Error{
                 code: "required",
                 source: %Jabbax.Document.ErrorSource{
                   pointer: "/relationships/address/data/attributes/city"
                 }
               },
               %Jabbax.Document.Error{
                 code: "invalid_inclusion",
                 source: %Jabbax.Document.ErrorSource{
                   pointer: "/relationships/address/data/relationships/country/data/attributes/code"
                 }
               }
             ]
           }
  end
end
