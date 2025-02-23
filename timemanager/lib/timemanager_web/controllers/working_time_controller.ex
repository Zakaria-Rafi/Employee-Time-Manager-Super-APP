defmodule TimemanagerWeb.WorkingTimeController do
  use TimemanagerWeb, :controller
  use TimemanagerWeb.Decorators.EnsureRole

  alias Timemanager.Workingtimes
  alias Timemanager.Workingtimes.WorkingTime
  alias Timemanager.Users

  action_fallback TimemanagerWeb.FallbackController

  def list_workingtimes_by_date(conn, %{"userId" => user_id} = params) do
    user = Users.get_user_by_id(user_id)
    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
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

      started_at =
        if Map.has_key?(params, "start") do
          case Integer.parse(params["start"]) do
            {start_unix, _} ->
              case DateTime.from_unix(start_unix) do
                {:ok, dt} -> dt
                _ -> nil
              end
            _ -> nil
          end
        else
          nil
        end

        ended_at =
          if Map.has_key?(params, "end") do
            case Integer.parse(params["end"]) do
              {end_unix, _} ->
                case DateTime.from_unix(end_unix) do
                  {:ok, dt} -> dt
                  _ -> nil
                end
              _ -> nil
            end
          else
            nil
          end

      workingtimes = Workingtimes.list_workingtimes_by_date(user_id, started_at, ended_at, page, page_size)

      if workingtimes == [] do
        conn
        |> put_status(:not_found)
        |> render(:error, message: "working_time.not_found")
      else
        render(conn, :index, workingtimes: workingtimes, ended_at: ended_at, started_at: started_at)
      end
    end
  end

  def get_clocks(conn, %{"userId" => user_id} = params) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      started_at =
        if Map.has_key?(params, "start") do
          case Integer.parse(params["start"]) do
            {start_unix, _} ->
              case DateTime.from_unix(start_unix) do
                {:ok, dt} -> dt
                _ -> nil
              end
            _ -> nil
          end
        else
          nil
        end

      ended_at =
        if Map.has_key?(params, "end") do
          case Integer.parse(params["end"]) do
            {end_unix, _} ->
              case DateTime.from_unix(end_unix) do
                {:ok, dt} -> dt
                _ -> nil
              end
            _ -> nil
          end
        else
          nil
        end

      clocks = Workingtimes.get_clocks(user_id, started_at, ended_at)

      if clocks == [] do
        conn
        |> put_status(:not_found)
        |> render(:error, message: "working_time.clock_not_found")
      else
        render(conn, :clocks, workingtimes: clocks, ended_at: ended_at, started_at: started_at)
      end
    end
  end

  def show(conn, %{"userId" => user_id, "id" => working_time_id}) do
    user = Users.get_user_by_id(user_id)

    if user in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "user.not_found")
    else
      working_time = Workingtimes.get_working_time_by_user(user_id, working_time_id)

      if working_time == nil do
        conn
        |> put_status(:not_found)
        |> render(:error, message: "working_time.not_found")
      else
        render(conn, :show, working_time: working_time)
      end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def create(conn, %{"userId" => user_id} = params) do
    case Users.get_user_by_id(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "user.not_found")

      _user ->
        cond do
          not Map.has_key?(params, "start") or not Map.has_key?(params, "end") ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "working_time.required_start_and_end")

          params["start"] in [nil, ""] or params["end"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "working_time.empty_start_and_end")

          true ->
            {start_unix, _} = Integer.parse(params["start"])
            {end_unix, _} = Integer.parse(params["end"])

            started_at = DateTime.from_unix!(start_unix)
            ended_at = DateTime.from_unix!(end_unix)

            working_time_params = %{
              "user_id" => user_id,
              "start" => started_at,
              "end" => ended_at
            }

            case Workingtimes.create_working_time(working_time_params) do
              {:ok, %WorkingTime{} = working_time} ->
                conn
                |> put_status(:created)
                |> render(:show, working_time: working_time)

              _error ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "working_time.creation_failed")
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def update(conn, %{"id" => id} = params) do
    case Workingtimes.get_working_time_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "working_time.not_found")

      working_time ->
        cond do
          not Map.has_key?(params, "start") or not Map.has_key?(params, "end") ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "working_time.required_start_and_end")

          params["start"] in [nil, ""] or params["end"] in [nil, ""] ->
            conn
            |> put_status(:bad_request)
            |> render(:error, message: "working_time.empty_start_and_end")

          true ->
            {start_unix, _} = Integer.parse(params["start"])
            {end_unix, _} = Integer.parse(params["end"])

            started_at = DateTime.from_unix!(start_unix)
            ended_at = DateTime.from_unix!(end_unix)

            working_time_params = %{
              "start" => started_at,
              "end" => ended_at
            }

            case Workingtimes.update_working_time(working_time, working_time_params) do
              {:ok, %WorkingTime{} = updated_working_time} ->
                render(conn, :show, working_time: updated_working_time)

              _error ->
                conn
                |> put_status(:bad_request)
                |> render(:error, message: "working_time.update_failed")
            end
        end
    end
  end

  @decorate is_granted(["ROLE_MANAGER", "ROLE_SUPERMANAGER"])
  def delete(conn, %{"id" => id}) do
    working_time = Workingtimes.get_working_time_by_id(id)

    if working_time in [nil, ""] do
      conn
      |> put_status(:not_found)
      |> render(:error, message: "working_time.not_found")
    else
      with {:ok, %WorkingTime{}} <- Workingtimes.delete_working_time(working_time) do
        send_resp(conn, :no_content, "")
      end
    end
  end
end
