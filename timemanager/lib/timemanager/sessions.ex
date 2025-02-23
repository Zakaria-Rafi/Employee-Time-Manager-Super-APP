defmodule Timemanager.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false
  alias Timemanager.Repo

  alias Timemanager.Sessions.Session

  @doc """
  Returns the session
  """
  def get_session_by_token(token) do
    case Repo.get_by(Session, token: token) do
      nil ->
        {:error, :not_found}

      session ->
        {:ok, session}
    end
  end

  @doc """
  Creates a session.
  """
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a session.
  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.
  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end
end
