defmodule Timemanager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team" do
    field :name, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime, default: nil

    many_to_many :users, Timemanager.Users.User, join_through: "team_user", on_delete: :delete_all
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:created_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> put_change(:updated_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end
end
