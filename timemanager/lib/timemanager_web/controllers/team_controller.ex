defmodule TimemanagerWeb.TeamController do
  use TimemanagerWeb, :controller
  use TimemanagerWeb.Decorators.EnsureRole

  alias Timemanager.Teams
  alias Timemanager.Teams.Team
  alias Timemanager.Users

  action_fallback TimemanagerWeb.FallbackController

  def get_all(conn, params) do
    page =
      if Map.has_key?(params, "page") do
        case Integer.parse(params["page"]) do
          {page, _} -> page
          _ -> 1
        end
      else
        1
      end

    page_size =
      if Map.has_key?(params, "page_size") do
        case Integer.parse(params["page_size"]) do
          {page_size, _} -> page_size
          _ -> 30
        end
      else
        30
      end

    teams = Teams.list_teams(page, page_size)

    if teams == [] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "teams.not_found")
    else
      render(conn, :index, teams: teams)
    end
  end

  def get_team_by_id(conn, %{"teamId" => team_id}) do
    team = Teams.get_team_by_id(team_id, true)

    if team in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "team.not_found")
    else
      render(conn, :show, team: team)
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def create(conn, params) do
    cond do
      params["name"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "team.form.empty_name")

      true ->
        team_params = %{
          "name" => params["name"]
        }

        case Teams.create_team(team_params) do
          {:ok, %Team{} = team} ->
            conn
            |> put_status(:created)
            |> render(:create_or_update, team: team)

            _error ->
              conn
              |> put_status(:bad_request)
              |> render(:error, message: "team.create_failed")
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def update(conn, %{"teamId" => team_id} = params) do
    case Teams.get_team_by_id(team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "team.not_found")

      team ->
        cond do
          params["name"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "team.form.empty_name")

          true ->
            team_params = %{
              "name" => params["name"]
            }

            case Teams.update_team(team, team_params) do
              {:ok, %Team{} = updated_team} ->
                render(conn, :create_or_update, team: updated_team)

              _error ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "team.update_failed")
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def add_user(conn, %{"teamId" => team_id, "userId" => user_id}) do
    team = Teams.get_team_by_id(team_id, true)

    case team do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "team.not_found")

      _ ->
        user = Users.get_user_by_id(user_id)

        case user do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(:error, message: "user.not_found")

          _ ->
            if user in team.users do
              conn
              |> put_status(:conflict)
              |> render(:error, message: "user.already_in_team")
            else
              case Teams.add_user_to_team(team, user) do
                {:ok, message} ->
                  conn
                  |> put_status(:ok)
                  |> render(:show, team: message)

                {:error, _changeset} ->
                  conn
                  |> put_status(:bad_request)
                  |> render(:error, message: "team.add_user_failed")
              end
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def remove_user(conn, %{"teamId" => team_id, "userId" => user_id}) do
    team = Teams.get_team_by_id(team_id, true)

    case team do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "team.not_found")

      _ ->
        user = Users.get_user_by_id(user_id)

        case user do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(:error, message: "user.not_found")

          _ ->
            if user in team.users do
              case Teams.remove_user_from_team(team, user) do
                {:ok, message} ->
                  conn
                  |> put_status(:ok)
                  |> render(:show, team: message)

                {:error, _changeset} ->
                  conn
                  |> put_status(:bad_request)
                  |> render(:error, message: "team.remove_user_failed")
              end
            else
              conn
              |> put_status(:conflict)
              |> render(:error, message: "user.not_in_team")
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def delete(conn, %{"teamId" => team_id}) do
    team = Teams.get_team_by_id(team_id)

    case team do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "team.not_found")

      _ ->
        case Teams.delete_team(team) do
          {:ok, _} ->
            send_resp(conn, :no_content, "")

          _error ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "team.delete_failed")
        end
    end
  end
end
