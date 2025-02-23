defmodule Timemanager.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :currently_working, :boolean, default: false
    field :last_login, :utc_datetime, default: nil
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime, default: nil
    field :roles, {:array, :string}, default: ["ROLE_USER"]

    # Establishing the one-to-many relationship
    has_many :clocks, Timemanager.Clocks.Clock, on_delete: :delete_all
    has_many :working_times, Timemanager.Workingtimes.WorkingTime, on_delete: :delete_all
    has_many :sessions, Timemanager.Sessions.Session, on_delete: :delete_all

    many_to_many :teams, Timemanager.Teams.Team, join_through: "team_user", on_delete: :delete_all, on_replace: :delete
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :currently_working, :last_login, :roles])
    |> validate_required([:username, :email, :password])
    |> unique_constraint(:email)
    |> put_created_at()
    |> put_updated_at()
    |> ensure_role_user()
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

  defp ensure_role_user(changeset) do
    roles = get_field(changeset, :roles, [])

    if "ROLE_USER" in roles do
      changeset
    else
      put_change(changeset, :roles, ["ROLE_USER" | roles])
    end
  end
end
