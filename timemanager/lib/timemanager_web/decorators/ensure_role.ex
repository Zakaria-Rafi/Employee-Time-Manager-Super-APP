defmodule TimemanagerWeb.Decorators.EnsureRole do
  use Decorator.Define, [is_granted: 1]

  def is_granted(roles, body, %{args: [conn, _params]}) do
    quote do
      current_user = unquote(conn).assigns[:current_user]

      if Enum.any?(current_user.roles, fn role -> role in unquote(roles) end) do
        unquote(body)
      else
        unquote(conn)
        |> put_status(403)
        |> json(%{error: "user.role.not_authorized"})
        |> halt()
      end
    end
  end
end
