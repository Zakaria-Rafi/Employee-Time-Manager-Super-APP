defmodule Timemanager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false
      add :currently_working, :boolean, default: false, null: false
      add :last_login, :utc_datetime, null: true
      add :created_at, :utc_datetime, default: fragment("NOW()")
      add :updated_at, :utc_datetime, null: true
      add :roles, {:array, :string}, default: ["ROLE_USER"]
    end
    create unique_index(:users, [:email])
  end
end
