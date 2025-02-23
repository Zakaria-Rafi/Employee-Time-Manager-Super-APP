defmodule Timemanager.Teams do
  import Ecto.Query, warn: false
  alias Timemanager.Repo

  alias Timemanager.Teams.Team
  alias Timemanager.Users.User

  @doc """
  Returns the list of teams.
  """
  def list_teams(page, page_size) do
    total_count = from(t in Team)
      |> select([t], count(t.id))
      |> Repo.one() || 0

    results = from(t in Team,
      left_join: u in assoc(t, :users),
      group_by: t.id,
      select: %{team: t, user_count: count(u.id)},
      limit: ^page_size,
      offset: (^page - 1) * ^page_size
    )
    |> Repo.all()

    total_pages = div(total_count, page_size) + rem(total_count, page_size)
    %{
      items: results,
      total_count: total_count,
      total_pages: total_pages,
      current_page: page,
      next_page: page < total_pages,
      prev_page: page > 1
    }
  end

  @doc """
  Returns a team by ID.
  """
  def get_team_by_id(team_id, include_users \\ false) do
    query = Repo.get(Team, team_id)

    if include_users do
      query |> Repo.preload(:users)
    else
      query
    end
  end

  @doc """
  Creates a team.
  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.
  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.
  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Adds a user to a team.
  """
  def add_user_to_team(%Team{} = team, %User{} = user) do
    changeset =
      Ecto.Changeset.change(team)
      |> Ecto.Changeset.put_assoc(:users, team.users ++ [user])

    case Repo.update(changeset) do
      {:ok, team} ->
        {:ok, team}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Removes a user from a team.
  """
  def remove_user_from_team(%Team{} = team, %User{} = user) do
    changeset =
      Ecto.Changeset.change(team)
      |> Ecto.Changeset.put_assoc(:users, Enum.reject(team.users, &(&1.id == user.id)))

    case Repo.update(changeset) do
      {:ok, updated_team} ->
        {:ok, updated_team}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
