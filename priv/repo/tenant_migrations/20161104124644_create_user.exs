defmodule MultiTenant.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string)
      add(:first_name, :string)
    end
  end
end
