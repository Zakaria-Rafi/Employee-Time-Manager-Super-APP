defmodule Timemanager.Clocks do
  @moduledoc """
  The Clocks context.
  """

  import Ecto.Query, warn: false
  alias Timemanager.Repo

  alias Timemanager.Clocks.Clock

  @doc """
  Get a clock by user.
  """
  def get_clock_by_user(user_id) do
    query = from c in Clock, where: c.user_id == ^user_id, order_by: [desc: c.created_at], limit: 1, select: c
    Repo.one(query)
  end

  @doc """
  Get a clock by user.
  """
  def get_by_id_and_user(user_id, clock_id) do
    query = from c in Clock, where: c.user_id == ^user_id and c.id == ^clock_id, select: c
    Repo.one(query)
  end

  @doc """
  Creates a clock.
  """
  def create_clock(attrs \\ %{}) do
    %Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a clock.
  """
  def update_clock(%Clock{} = clock, attrs \\ %{}) do
    clock
    |> Clock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clock.
  """
  def delete_clock(%Clock{} = clock) do
    Repo.delete(clock)
  end
end
