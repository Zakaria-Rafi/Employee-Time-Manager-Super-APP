defmodule Timemanager.Repo.Migrations.CreateWorkingtime do
  use Ecto.Migration

  def change do
    create table(:workingtimes) do
      add :start, :utc_datetime
      add :end, :utc_datetime
      add :created_at, :utc_datetime, default: fragment("NOW()")
      add :updated_at, :utc_datetime, null: true
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:workingtimes, [:user_id])
  end
end
