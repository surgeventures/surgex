defmodule Surgex.ForeignUser do
  @moduledoc false

  use Ecto.Schema

  schema "foreign_users" do
    field(:provider_id, :integer)
    field(:name, :string)
    field(:email, :string)
  end
end
