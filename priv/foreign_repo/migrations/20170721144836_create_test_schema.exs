defmodule Surgex.OtherRepo.Migrations.CreateTestSchema do
  use Ecto.Migration

  def change do
    create table(:foreign_users) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :provider_id, :integer, null: false
    end

    create index(:foreign_users, [:email], unique: true)
  end
end
