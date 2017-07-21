defmodule Surgex.User do
  use Ecto.Schema
  alias Surgex.PhoneNumber

  schema "users" do
    field :provider_id, :integer
    field :name, :string
    field :email, :string
    field :phone, PhoneNumber
  end
end
