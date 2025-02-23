defmodule Timemanager.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :created_at, :utc_datetime, default: fragment("NOW()")
      add :updated_at, :utc_datetime, null: true
    end
  end
end
