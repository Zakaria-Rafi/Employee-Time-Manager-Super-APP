defmodule TimemanagerWeb.ClockControllerTest do
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

  test "with bad user id ", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/clocks/0")
    assert json_response(conn, 404)["error"] == "user.not_found"
  end

  test "with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/clocks/#{user_id}")
    response_status = conn.status
    assert response_status in [200, 404]
  end

  test "without user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = post(conn, ~p"/api/clocks/0")
    assert json_response(conn, 404)["error"] == "user.not_found"
  end

  test "clock in with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = post(conn, ~p"/api/clocks/#{user_id}")
    assert json_response(conn, 201) != nil
  end

  test "clock out with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = post(conn, ~p"/api/clocks/#{user_id}")
    assert json_response(conn, 201) != nil
  end

  test "clock in offline with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    current_time = DateTime.utc_now()

    conn = post(conn, ~p"/api/clocks/#{user_id}/offline", %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    assert json_response(conn, 201) != nil
  end

  test "clock out offline with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    current_time = DateTime.utc_now()

    conn = post(conn, ~p"/api/clocks/#{user_id}/offline", %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    assert json_response(conn, 201) != nil
  end

  test "get offline clock with user id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    current_time = DateTime.utc_now()

    conn = post(conn, ~p"/api/clocks/#{user_id}/offline", %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    clock = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/clocks/#{user_id}/clock/#{clock["id"]}")
    assert json_response(conn, 200) == clock
  end

  test "Update offline clock with user id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    current_time = DateTime.utc_now()

    conn = post(conn, ~p"/api/clocks/#{user_id}/offline", %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    clock = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    conn = put(conn, ~p"/api/clocks/#{user_id}/clock/#{clock["id"]}",  %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    assert json_response(conn, 200)["id"] == clock["id"]
  end

  test "Delete offline clock with user id", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    current_time = DateTime.utc_now()

    conn = post(conn, ~p"/api/clocks/#{user_id}/offline", %{
      time: DateTime.to_unix(current_time) |> Integer.to_string(),
      status: "true"
    })
    clock = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", manager.csrf_token)
      |> put_req_header("authorization", "Bearer #{manager.token}")

    conn = delete(conn, ~p"/api/clocks/#{user_id}/clock/#{clock["id"]}")
    assert response(conn, 204)
  end
end
