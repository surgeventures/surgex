defmodule Surgex.Repo.Migrations.CreateTestSchema do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :provider_id, :integer, null: false
    end

    create index(:users, [:email], unique: true)

    create table(:other_users) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :provider_id, :integer, null: false
    end

    create index(:other_users, [:email], unique: true)
  end
end
