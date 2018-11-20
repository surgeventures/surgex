defmodule Surgex.OtherRepo.Migrations.CreateTestSchema do
  use Ecto.Migration

  def change do
    create table(:foreign_users) do
      add(:name, :string)
      add(:email, :string)
      add(:provider_id, :integer, null: false)
    end
  end
end
