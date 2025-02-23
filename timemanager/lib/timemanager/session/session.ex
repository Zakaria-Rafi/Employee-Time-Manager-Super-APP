defmodule Timemanager.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :token, :string
    field :ip, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime, default: nil

    belongs_to :user, Timemanager.Users.User
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:token, :ip, :user_id])
    |> validate_required([:token, :ip, :user_id])
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
