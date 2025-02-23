defmodule TimemanagerWeb.UserController do
  use TimemanagerWeb, :controller
  use TimemanagerWeb.Decorators.EnsureRole

  alias Timemanager.Users
  alias Timemanager.Users.User

  action_fallback TimemanagerWeb.FallbackController

  def index(conn, params) do
    if Map.has_key?(params, "email") || Map.has_key?(params, "username") do
      if params["email"] in [nil, ""] or params["username"] in [nil, ""] do
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "user.empty_username_and_email")
      else
        user = Users.get_user_by_query(params["email"], params["username"])
        if user == nil do
          conn
          |> put_status(:not_found)
          |> render(:error, message: "user.not_found")
        else
          render(conn, :show, user: user)
        end
      end
    else
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

      users = Users.list_users(page, page_size)

      if users == [] do
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")
      else
        render(conn, :users, users: users)
      end
    end
  end

  def show(conn, %{"userId" => user_id}) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      render(conn, :show, user: user)
    end
  end

  def me(conn, _params) do
    render(conn, :show, user: conn.assigns[:current_user])
  end

  def teams(conn, %{"userId" => user_id}) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      render(conn, :teams, teams: Users.get_teams(user))
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def create(conn, params) do
    cond do
      params["username"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "user.form.empty_username")

      params["email"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "user.form.empty_email")

      not valid_email?(params["email"]) ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "user.form.invalid_email")

      params["password"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "user.form.empty_password")

      true ->
        user_params = %{
          "username" => params["username"],
          "email" => params["email"],
          "password" => Bcrypt.Base.hash_password(params["password"], Bcrypt.Base.gen_salt(12, true))
        }

        case Users.create_user(user_params) do
          {:ok, %User{} = user} ->
            conn
            |> put_status(:created)
            |> render(:show, user: user)

          _error ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.creation_failed")
        end
    end
  end

  def update(conn, %{"userId" => user_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        cond do
          params["username"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.empty_username")

          params["email"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.empty_email")

          not valid_email?(params["email"]) ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.invalid_email")

          true ->
            user_params = %{
              "username" => params["username"],
              "email" => params["email"]
            }

            user_params =
              if Map.has_key?(params, "password") and params["password"] not in [nil, ""] do
                hashed_password = Bcrypt.Base.hash_password(params["password"], Bcrypt.Base.gen_salt(12, true))
                Map.put(user_params, "password", hashed_password)
              else
                user_params
              end

            case Users.update_user(user, user_params) do
              {:ok, %User{} = updated_user} ->
                render(conn, :show, user: updated_user)

              _error ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "user.update_failed")
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def delete(conn, %{"userId" => user_id}) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      if conn.assigns[:current_user].id == user.id do
        conn
        |> put_status(:conflict)
        |> render(:error, message: "user.cannot_delete_self")
      else
        with {:ok, %User{}} <- Users.delete_user(user) do
          send_resp(conn, :no_content, "")
        end
      end
    end
  end

  @decorate is_granted(["ROLE_SUPERMANAGER"])
  def promote(conn, %{"userId" => user_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        cond do
          params["role"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.empty_role")

          params["role"] not in ["ROLE_MANAGER", "ROLE_SUPERMANAGER"] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.invalid_role")

          true ->
            if params["role"] in user.roles do
              conn
              |> put_status(:bad_request)
              |> render(:error, message: "user.role_already_exists")
            else
              updated_roles = Enum.uniq([params["role"] | user.roles])

              user_params = %{
                "roles" => updated_roles
              }

              if conn.assigns[:current_user].id == user.id do
                conn
                |> put_status(:conflict)
                |> render(:error, message: "user.cannot_promote_self")
              else
                case Users.update_user(user, user_params) do
                  {:ok, %User{} = updated_user} ->
                    render(conn, :show, user: updated_user)

                  _error ->
                    conn
                    |> put_status(:bad_request)
                    |> render(:error, message: "user.promote_failed")
                end
              end
            end
        end
    end
  end

  @decorate is_granted(["ROLE_SUPERMANAGER"])
  def demote(conn, %{"userId" => user_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        cond do
          params["role"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.empty_role")

          params["role"] not in ["ROLE_MANAGER", "ROLE_SUPERMANAGER"] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "user.form.invalid_role")

          true ->
            if params["role"] in user.roles do
              updated_roles = Enum.filter(user.roles, fn role -> role != params["role"] end)

              user_params = %{
                "roles" => updated_roles
              }

              if conn.assigns[:current_user].id == user.id do
                conn
                |> put_status(:conflict)
                |> render(:error, message: "user.cannot_demote_self")
              else
                case Users.update_user(user, user_params) do
                  {:ok, %User{} = updated_user} ->
                    render(conn, :show, user: updated_user)

                  _error ->
                    conn
                    |> put_status(:bad_request)
                    |> render(:error, message: "user.demote_failed")
                end
              end
            else
              conn
              |> put_status(:bad_request)
              |> render(:error, message: "user.role_not_found")
            end
        end
    end
  end

  defp valid_email?(email) do
    regex = ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/
    Regex.match?(regex, email)
  end
end
