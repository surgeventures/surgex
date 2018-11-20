defmodule Surgex.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :surgex, adapter: Ecto.Adapters.Postgres
end
