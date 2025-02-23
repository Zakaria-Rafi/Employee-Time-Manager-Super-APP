defmodule TimemanagerWeb.SessionController do
  use TimemanagerWeb, :controller

  alias Timemanager.Users
  alias Timemanager.Sessions
  alias Timemanager.Sessions.Session

  action_fallback TimemanagerWeb.FallbackController

  def login(conn, params) do
    cond do
      !Map.has_key?(params, "email") or !Map.has_key?(params, "password") ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "auth.required_email_and_password")

      params["email"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "auth.form.empty_email")

      params["password"] in [nil, ""] ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "auth.form.empty_password")

        true ->
          case Users.authenticate_user(params["email"], params["password"]) do
            {:ok, user} ->
              token = TimemanagerWeb.Token.signJWT(%{user_id: user.id})
              token_csrf = TimemanagerWeb.Token.signCSRF(%{user_id: user.id})

              case {token, token_csrf} do
                {{:ok, token}, {:ok, token_csrf}} ->
                  Sessions.create_session(%{
                    user_id: user.id,
                    token: token,
                    ip: conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
                  })

                  Users.update_user(user, %{last_login: DateTime.utc_now() |> DateTime.truncate(:second)})

                  conn
                  |> put_status(:ok)
                  |> render(:token, token: token, csrf_token: token_csrf)

                _ ->
                  conn
                  |> put_status(:bad_request)
                  |> render(:error, message: "auth.token_error")
              end

            _ ->
              conn
              |> put_status(:bad_request)
              |> render(:error, message: "auth.invalid_credentials")
          end
      end
    end

  def logout(conn, _params) do
    with {:ok, %Session{}} <- Sessions.delete_session(conn.assigns[:session]) do
      send_resp(conn, :no_content, "")
    end
  end
end
