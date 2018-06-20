defmodule Surgex.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Surgex.Repo
  alias Surgex.{OtherUser, User}

  def user_factory do
    %User{
      provider_id: 1,
      name: "John",
      email: sequence(:user_email, &"john-#{&1}@example.com"),
      phone: "48600700800"
    }
  end

  def other_user_factory do
    %OtherUser{
      provider_id: 1,
      name: "John",
      email: sequence(:other_user_email, &"john-#{&1}@example.com"),
      phone: "48600700800"
    }
  end
end
