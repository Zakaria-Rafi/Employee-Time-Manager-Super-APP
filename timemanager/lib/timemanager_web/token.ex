defmodule TimemanagerWeb.Token do
  @secret Joken.Signer.create("HS256", System.get_env("JWT_PASSPHRASE"))

  @doc """
  Create token for given data
  """
  def signJWT(data \\ %{}) do
    current_time = DateTime.utc_now()
    iat = current_time |> DateTime.to_unix()
    exp = current_time |> DateTime.add(24, :hour) |> DateTime.to_unix()

    claims = Map.merge(data, %{"exp" => exp, "iat" => iat})

    case Joken.encode_and_sign(claims, @secret) do
      {:ok, token, _full_claims} -> {:ok, token}
      _error -> {:error, :unauthenticated}
    end
  end


  @doc """
  Verify token
  """
  def verifyJWT(token) do
    case Joken.verify_and_validate(%{}, token, @secret) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end

  @doc """
  Create CSRF token for given data
  """
  @spec signCSRF(map()) :: binary()
  def signCSRF(data \\ %{}) do
    {:ok, Phoenix.Token.sign(TimemanagerWeb.Endpoint, System.get_env("JWT_PASSPHRASE"), data)}
  end

  @doc """
  Verify CSRF token
  """
  def verifyCSRF(token) do
    case Phoenix.Token.verify(TimemanagerWeb.Endpoint, System.get_env("JWT_PASSPHRASE"), token) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
