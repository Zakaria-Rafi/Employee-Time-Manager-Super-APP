defmodule TimemanagerWeb.UserJSON do
  alias Timemanager.Users.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    data(user)
  end

  @doc """
  Renders a list of teams for an user.
  """
  def teams(%{teams: team}) do
    for team <- team do
      %{
        id: team.id,
        name: team.name,
        created_at: team.created_at,
        updated_at: team.updated_at
      }
    end
  end

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end

  def users(%{users: users}) do
    %{
      items: Enum.map(users.items, &data/1),
      total_count: users.total_count,
      total_pages: users.total_pages,
      current_page: users.current_page,
      next_page: users.next_page,
      prev_page: users.prev_page
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      roles: user.roles,
      currently_working: user.currently_working,
      last_login: user.last_login,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
