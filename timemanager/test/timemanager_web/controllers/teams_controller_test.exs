defmodule TimemanagerWeb.TeamsControllerTest do
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

  test "List teams", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/teams")
    assert json_response(conn, 200) != nil
  end

  test "Get team", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)
    conn = post(conn, ~p"/api/teams/", %{
      name: "Team #{Faker.String.base64()}",
    })
    team = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~p"/api/teams/#{team["id"]}")
    assert json_response(conn, 200)["id"] == team["id"]
    assert json_response(conn, 200)["name"] == team["name"]
  end

  test "Create team", %{conn: conn, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    team_name = "Team #{Faker.String.base64()}"
    conn = post(conn, ~p"/api/teams/", %{
      name: team_name,
    })
    assert json_response(conn, 201)["name"] == team_name
  end

  test "Update team", %{conn: conn, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = post(conn, ~p"/api/teams/", %{
      name: "Team #{Faker.String.base64()}",
    })
    team = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = put(conn, ~p"/api/teams/#{team["id"]}", %{
      name: "Team #{Faker.String.base64()}",
    })
    assert json_response(conn, 200)["id"] == team["id"]
  end

  test "Add user to team", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = post(conn, ~p"/api/teams/", %{
      name: "Team #{Faker.String.base64()}",
    })
    team = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = put(conn, ~p"/api/teams/#{team["id"]}/add/#{user_id}")
    assert response(conn, 200)
  end

  test "Remove user from team", %{conn: conn, employee: employee, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = post(conn, ~p"/api/teams/", %{
      name: "Team #{Faker.String.base64()}",
    })
    team = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = put(conn, ~p"/api/teams/#{team["id"]}/add/#{user_id}")
    assert response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = delete(conn, ~p"/api/teams/#{team["id"]}/remove/#{user_id}")
    assert response(conn, 200)
  end

  test "Delete team", %{conn: conn, manager: manager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = post(conn, ~p"/api/teams/", %{
      name: "Team #{Faker.String.base64()}",
    })
    team = json_response(conn, 201)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{manager.token}")
      |> put_req_header("x-csrf-token", manager.csrf_token)

    conn = delete(conn, ~p"/api/teams/#{team["id"]}")
    assert response(conn, 204)
  end
end
