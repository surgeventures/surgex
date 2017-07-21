defmodule Surgex.ForeignFactory do
  use ExMachina.Ecto, repo: Surgex.ForeignRepo
  alias Surgex.ForeignUser

  def foreign_user_factory do
    %ForeignUser{
      provider_id: 1,
      name: "John",
      email: sequence(:user_email, &"john-#{&1}@example.com"),
      phone: "48600700800",
    }
  end
end
