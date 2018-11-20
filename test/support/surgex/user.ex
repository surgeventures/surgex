defmodule Surgex.User do
  @moduledoc false

  use Ecto.Schema

  schema "users" do
    field(:provider_id, :integer)
    field(:name, :string)
    field(:email, :string)
  end
end
