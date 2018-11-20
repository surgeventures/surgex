defmodule Surgex.Repo.Migrations.CreateTestSchema do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:email, :string)
      add(:provider_id, :integer, null: false)
    end

    create table(:other_users) do
      add(:name, :string)
      add(:email, :string)
      add(:provider_id, :integer, null: false)
    end
  end
end
