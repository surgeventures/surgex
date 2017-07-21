defmodule Surgex.ForeignUser do
  use Ecto.Schema
  alias Surgex.PhoneNumber

  schema "foreign_users" do
    field :provider_id, :integer
    field :name, :string
    field :email, :string
    field :phone, PhoneNumber
  end
end
