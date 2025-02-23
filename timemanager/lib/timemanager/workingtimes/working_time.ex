defmodule Timemanager.Workingtimes.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workingtimes" do
    field :end, :utc_datetime
    field :start, :utc_datetime
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime, default: nil

    belongs_to :user, Timemanager.Users.User  # Establishing the belongs_to relationship
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
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
