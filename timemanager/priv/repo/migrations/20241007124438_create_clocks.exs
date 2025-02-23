defmodule Timemanager.Repo.Migrations.CreateClocks do
  use Ecto.Migration

  def change do
    create table(:clocks) do
      add :time, :utc_datetime
      add :status, :boolean, default: false, null: false
      add :to_check, :boolean, default: false, null: false
      add :created_at, :utc_datetime, default: fragment("NOW()")
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:clocks, [:user_id])
  end
end
