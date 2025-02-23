defmodule Timemanager.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Timemanager.Repo

  alias Timemanager.Users.User
  alias Timemanager.Teams.Team

  @doc """
  Returns the list of users.
  """
  def list_users(page, page_size) do
    total_count = from(u in User)
      |> select([u], count(u.id))
      |> Repo.one() || 0

    results = from(u in User,
      select: u,
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
  Retrieves a user by email and username.
  """
  def get_user_by_query(email, username) do
    query = from u in User, where: u.email == ^email and u.username == ^username, select: u
    Repo.one(query)
  end

  @doc """
  Retrieves a user by ID.
  """
  def get_user_by_id(id) do
    query = from u in User, where: u.id == ^id, select: u
    Repo.one(query)
  end

  @doc """
  Retrieves a user by email.
  """
  def get_teams(%User{} = user) do
    query = from t in Team,
      join: u in assoc(t, :users),
      where: u.id == ^user.id,
      select: t

    Repo.all(query)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Login user by email and password
  """
  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email, select: u
    result = Repo.one(query)

    case result do
      nil -> {:error, "User not found"}
      user ->
        case Bcrypt.verify_pass(password, user.password) do
          true -> {:ok, user}
          false -> {:error, "Password is incorrect"}
        end
    end
  end
end
