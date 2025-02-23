defmodule TimemanagerWeb.TeamJSON do
  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{
      items: for(team <- teams.items, do: %{
        id: team.team.id,
        name: team.team.name,
        user_count: team.user_count,
        created_at: team.team.created_at,
        updated_at: team.team.updated_at
      }),
      total_count: teams.total_count,
      total_pages: teams.total_pages,
      current_page: teams.current_page,
      next_page: teams.next_page,
      prev_page: teams.prev_page
    }
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{
      id: team.id,
      name: team.name,
      users: for(user <- team.users, do: TimemanagerWeb.UserJSON.show(%{user: user})),
      created_at: team.created_at,
      updated_at: team.updated_at
    }
  end

  @doc """
  Renders a team after create.
  """
  def create_or_update(%{team: team}) do
    %{
      id: team.id,
      name: team.name,
      created_at: team.created_at,
      updated_at: team.updated_at
    }
  end

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end
end
