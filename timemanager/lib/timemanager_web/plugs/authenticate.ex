defmodule TimemanagerWeb.Plug.Authenticate do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
      {:ok, data} <- TimemanagerWeb.Token.verifyJWT(token),
      {:ok, session} <- Timemanager.Sessions.get_session_by_token(token) do
      conn
      |> assign(:current_user, Timemanager.Users.get_user_by_id(data["user_id"]))
      |> assign(:session, session)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "auth.invalid_token"}))
        |> halt()
    end
  end
end
