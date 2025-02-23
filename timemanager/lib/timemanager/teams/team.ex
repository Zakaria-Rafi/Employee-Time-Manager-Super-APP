defmodule Timemanager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime, default: nil

    many_to_many :users, Timemanager.Users.User, join_through: "team_user", on_delete: :delete_all, on_replace: :delete
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_created_at()
    |> put_updated_at()
  end

  defp put_created_at(changeset) do
    if changeset.data.created_at == nil do
      change(changeset, created_at: DateTime.utc_now() |> DateTime.truncate(:second))
    else
      changeset
    end
  end

  defp put_updated_at(changeset) do
    change(changeset, updated_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end
end
