defmodule TimemanagerWeb.WorkingTimeControllerTest do
  use TimemanagerWeb.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")
    conn = post(conn, ~p"/api/login", %{email: "employee@epitech.eu", password: "azertyuiop"})
    employee_token = json_response(conn, 200)["token"]
    employee_csrf_token = json_response(conn, 200)["csrf_token"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
    conn = post(conn, ~p"/api/login", %{email: "manager@epitech.eu", password: "azertyuiop"})
    manager_token = json_response(conn, 200)["token"]
    manager_csrf_token = json_response(conn, 200)["csrf_token"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn, employee: %{token: employee_token, csrf_token: employee_csrf_token}, manager: %{token: manager_token, csrf_token: manager_csrf_token}}
  end

  test "List working times by user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/workingtime/#{user_id}")
    assert json_response(conn, 200) != nil
  end

  test "List working times and clocks by user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/workingtime/#{user_id}/clocks")
    assert json_response(conn, 200) != nil
  end

  test "Get working time by user id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    start_time = DateTime.utc_now()
    end_time = DateTime.utc_now() |> DateTime.add(8, :hour)

    conn = post(conn, ~p"/api/workingtime/#{user_id}", %{
      start: DateTime.to_unix(start_time) |> Integer.to_string(),
      end: DateTime.to_unix(end_time) |> Integer.to_string()
    })
    working_time = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/workingtime/#{user_id}/#{working_time["id"]}")
    assert json_response(conn, 200) == working_time
  end

  test "Create working time by user id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    start_time = DateTime.utc_now()
    end_time = DateTime.utc_now() |> DateTime.add(8, :hour)

    conn = post(conn, ~p"/api/workingtime/#{user_id}", %{
      start: DateTime.to_unix(start_time) |> Integer.to_string(),
      end: DateTime.to_unix(end_time) |> Integer.to_string()
    })
    assert json_response(conn, 201)["user"] == user_id
    assert String.slice(json_response(conn, 201)["start"], 0..18) == String.slice(DateTime.to_iso8601(start_time), 0..18)
    assert String.slice(json_response(conn, 201)["end"], 0..18) == String.slice(DateTime.to_iso8601(end_time), 0..18)
  end

  test "Update working time by id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    start_time = DateTime.utc_now()
    end_time = DateTime.utc_now() |> DateTime.add(8, :hour)

    conn = post(conn, ~p"/api/workingtime/#{user_id}", %{
      start: DateTime.to_unix(start_time) |> Integer.to_string(),
      end: DateTime.to_unix(end_time) |> Integer.to_string()
    })
    working_time = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    start_time = DateTime.utc_now() |> DateTime.add(1, :day)
    end_time = DateTime.utc_now() |> DateTime.add(1, :day) |> DateTime.add(8, :hour)
    conn = put(conn, ~p"/api/workingtime/#{working_time["id"]}", %{
      start: DateTime.to_unix(start_time) |> Integer.to_string(),
      end: DateTime.to_unix(end_time) |> Integer.to_string()
    })
    assert json_response(conn, 200)["id"] == working_time["id"]
    assert String.slice(json_response(conn, 200)["start"], 0..18) == String.slice(DateTime.to_iso8601(start_time), 0..18)
    assert String.slice(json_response(conn, 200)["end"], 0..18) == String.slice(DateTime.to_iso8601(end_time), 0..18)
  end

  test "Delete working time by id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    start_time = DateTime.utc_now()
    end_time = DateTime.utc_now() |> DateTime.add(8, :hour)

    conn = post(conn, ~p"/api/workingtime/#{user_id}", %{
      start: DateTime.to_unix(start_time) |> Integer.to_string(),
      end: DateTime.to_unix(end_time) |> Integer.to_string()
    })
    working_time = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    conn = delete(conn, ~p"/api/workingtime/#{working_time["id"]}")
    assert response(conn, 204)
  end
end
