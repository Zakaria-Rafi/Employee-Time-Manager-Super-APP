defmodule TimemanagerWeb.Plug.CSRFProtection do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with [token] <- get_req_header(conn, "x-csrf-token"), {:ok, _data} <- TimemanagerWeb.Token.verifyCSRF(token) do
      conn
      |> assign(:csrf, token)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "auth.invalid_csrf_token"}))
        |> halt()
    end
  end
end
