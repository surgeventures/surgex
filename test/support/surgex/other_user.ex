defmodule Surgex.OtherUser do
  @moduledoc false

  use Ecto.Schema

  schema "other_users" do
    field(:provider_id, :integer)
    field(:name, :string)
    field(:email, :string)
  end
end
