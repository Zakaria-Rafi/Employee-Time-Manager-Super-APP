defmodule Timemanager.Clocks.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clocks" do
    field :time, :utc_datetime
    field :status, :boolean, default: false
    field :to_check, :boolean, default: false
    field :created_at, :utc_datetime

    belongs_to :user, Timemanager.Users.User  # Establishing the belongs_to relationship
  end

  @doc false
  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id, :to_check])
    |> validate_required([:time, :status, :user_id])
    |> put_created_at()
  end

  defp put_created_at(changeset) do
    if changeset.data.created_at == nil do
      change(changeset, created_at: DateTime.utc_now() |> DateTime.truncate(:second))
    else
      changeset
    end
  end
end
