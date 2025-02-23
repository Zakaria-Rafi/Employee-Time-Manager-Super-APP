defmodule Timemanager.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string
      add :ip, :string
      add :created_at, :utc_datetime, default: fragment("NOW()")
      add :updated_at, :utc_datetime, null: true
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:sessions, [:user_id])
  end
end
