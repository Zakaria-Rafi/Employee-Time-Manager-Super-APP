defmodule TimemanagerWeb.SessionJSON do
  @doc """
  Renders a token.
  """
  def token(%{token: token, csrf_token: csrf_token}) do
    %{token: token, csrf_token: csrf_token}
  end

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end
end
