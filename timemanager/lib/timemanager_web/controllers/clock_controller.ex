defmodule TimemanagerWeb.ClockController do
  use TimemanagerWeb, :controller
  use TimemanagerWeb.Decorators.EnsureRole

  alias Timemanager.Clocks
  alias Timemanager.Clocks.Clock
  alias Timemanager.Users

  action_fallback TimemanagerWeb.FallbackController

  def show(conn, %{"userId" => user_id}) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      clock = Clocks.get_clock_by_user(user_id)
      if clock == nil do
        conn
        |> put_status(:not_found)
        |> render(:error, message: "clock.not_found")
      else
        render(conn, :show, clock: clock)
      end
    end
  end

  def create(conn, %{"userId" => user_id}) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        work_status = not user.currently_working

        clock_params = %{
          "user_id" => user_id,
          "time" => DateTime.utc_now(),
          "status" => work_status
        }

        case Clocks.create_clock(clock_params) do
          {:ok, %Clock{} = clock} ->
            Users.update_user(user, %{"currently_working" => work_status})

            conn
            |> put_status(:created)
            |> render(:show, clock: clock)

          _error ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "clock.creation_failed")
        end
    end
  end

  def create_offline(conn, %{"userId" => user_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      _user ->
        cond do
          params["time"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "clock.form.empty_time")

          params["status"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "clock.form.empty_status")

          params["status"] not in ["true", "false"] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "clock.form.invalid_status")

          true ->
            {time_unix, ""} = Integer.parse(params["time"])
            case DateTime.from_unix(time_unix) do
              {:error, _} ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "clock.form.invalid_time")

              {:ok, datetime} ->
                clock_params = %{
                  "user_id" => user_id,
                  "time" => datetime,
                  "status" => params["status"],
                  "to_check" => true
                }

                case Clocks.create_clock(clock_params) do
                  {:ok, %Clock{} = clock} ->
                    conn
                    |> put_status(:created)
                    |> render(:show, clock: clock)

                  _error ->
                    conn
                    |> put_status(:bad_request)
                    |> render(:error, message: "clock.creation_failed")
                end
            end
        end
    end
  end

  def show_offline(conn, %{"userId" => user_id, "clockId" => clock_id}) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        case Clocks.get_by_id_and_user(user.id, clock_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(:error, message: "clock.not_found")

          clock ->
            render(conn, :show, clock: clock)
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def update_offline(conn, %{"userId" => user_id, "clockId" => clock_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        case Clocks.get_by_id_and_user(user.id, clock_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(:error, message: "clock.not_found")

          clock ->
            cond do
              params["time"] in [nil, ""] ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "clock.form.empty_time")

              params["status"] in [nil, ""] ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "clock.form.empty_status")

              params["status"] not in ["true", "false"] ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "clock.form.invalid_status")

              true ->
                {time_unix, ""} = Integer.parse(params["time"])
                case DateTime.from_unix(time_unix) do
                  {:error, _} ->
                    conn
                    |> put_status(:bad_request)
                    |> render(:error, message: "clock.form.invalid_time")

                  {:ok, datetime} ->
                    clock_params = %{
                      "time" => datetime,
                      "status" => params["status"],
                      "to_check" => false
                    }

                    case Clocks.update_clock(clock, clock_params) do
                      {:ok, %Clock{} = clock} ->
                        conn
                        |> put_status(:ok)
                        |> render(:show, clock: clock)

                      _error ->
                        conn
                        |> put_status(:bad_request)
                        |> render(:error, message: "clock.update_failed")
                    end
                end
              end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def delete_offline(conn, %{"userId" => user_id, "clockId" => clock_id}) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      user ->
        case Clocks.get_by_id_and_user(user.id, clock_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(:error, message: "clock.not_found")

          clock ->
            with {:ok, %Clock{}} <- Clocks.delete_clock(clock) do
              send_resp(conn, :no_content, "")
            end
        end
    end
  end
end
