defmodule TimemanagerWeb.UserControllerTest do
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
    conn = post(conn, ~p"/api/login", %{email: "supermanager@epitech.eu", password: "azertyuiop"})
    supermanager_token = json_response(conn, 200)["token"]
    supermanager_csrf_token = json_response(conn, 200)["csrf_token"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn, employee: %{token: employee_token, csrf_token: employee_csrf_token}, manager: %{token: manager_token, csrf_token: manager_csrf_token}, supermanager: %{token: supermanager_token, csrf_token: supermanager_csrf_token}}
  end

  test "Get all user", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users")
    assert json_response(conn, 200) != nil
  end

  test "Get an user with empty username and email", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users", %{username: "", email: ""})
    assert json_response(conn, 400)["error"] == "user.empty_username_and_email"
  end

  test "Get an user with username and email", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)

    conn = get(conn, ~p"/api/users", %{username: "employee", email: "employee@epitech.eu"})
    assert json_response(conn, 200)["username"] == "employee"
    assert json_response(conn, 200)["email"] == "employee@epitech.eu"
  end

  test "Get an user with id", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~s"/api/users/#{user_id}")
    assert json_response(conn, 200)["username"] == "employee"
    assert json_response(conn, 200)["email"] == "employee@epitech.eu"
  end

  test "Get teams for an user", %{conn: conn, employee: employee} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user_id = json_response(conn, 200)["id"]

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", employee.csrf_token)
      |> put_req_header("authorization", "Bearer #{employee.token}")

    conn = get(conn, ~s"/api/users/#{user_id}/teams")
    assert json_response(conn, 200) != nil
  end

  describe "Create user" do
    test "with unauthorized role", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)

      conn = post(conn, ~s"/api/users", %{username: "", email: "", password: ""})
      assert json_response(conn, 403)["error"] == "user.role.not_authorized"
    end

    test "without username, email and password", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = post(conn, ~s"/api/users", %{username: "", email: "", password: ""})
      assert json_response(conn, 400)["error"] == "user.form.empty_username"
    end

    test "with username and without email and password", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = post(conn, ~p"/api/users", %{username: "test", email: nil, password: nil})
      assert json_response(conn, 400)["error"] == "user.form.empty_email"
    end

    test "with username and with bad email and without password", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = post(conn, ~p"/api/users", %{username: "test", email: "employee@e", password: nil})
      assert json_response(conn, 400)["error"] == "user.form.invalid_email"
    end

    test "with existing username, email and password", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = post(conn, ~p"/api/users", %{username: "employee", email: "employee@epitech.eu", password: "azertyuiop"})
      assert json_response(conn, 400)["error"] == "user.creation_failed"
    end

    test "with username, email and password", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      full_name = Faker.Person.name()
      email = Faker.Internet.email()
      conn = post(
        conn,
        ~p"/api/users", %{
          username: full_name,
          email: email,
          password: "azertyuiop"
        }
      )
      assert json_response(conn, 201)["username"] == full_name
      assert json_response(conn, 201)["email"] == email
    end
  end

  describe "Update user" do
    test "with bad user id", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)

      conn = put(conn, ~p"/api/users/0", %{username: nil, email: nil})
      assert json_response(conn, 404)["error"] == "user.not_found"
    end

    test "without username and email", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)
      conn = get(conn, ~p"/api/users/me")
      user_id = json_response(conn, 200)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-csrf-token", employee.csrf_token)
        |> put_req_header("authorization", "Bearer #{employee.token}")

      conn = put(conn, ~p"/api/users/#{user_id}", %{username: "", email: ""})
      assert json_response(conn, 400)["error"] == "user.form.empty_username"
    end

    test "with username and without email", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)
      conn = get(conn, ~p"/api/users/me")
      user_id = json_response(conn, 200)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-csrf-token", employee.csrf_token)
        |> put_req_header("authorization", "Bearer #{employee.token}")
      full_name = Faker.Person.name()

      conn = put(conn, ~p"/api/users/#{user_id}", %{username: full_name, email: ""})
      assert json_response(conn, 400)["error"] == "user.form.empty_email"
    end

    test "with username and invalid email", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)
      conn = get(conn, ~p"/api/users/me")
      user_id = json_response(conn, 200)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-csrf-token", employee.csrf_token)
        |> put_req_header("authorization", "Bearer #{employee.token}")
      full_name = Faker.Person.name()

      conn = put(conn, ~p"/api/users/#{user_id}", %{username: full_name, email: "employee@e"})
      assert json_response(conn, 400)["error"] == "user.form.invalid_email"
    end

    test "with username and existing email", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)
      conn = get(conn, ~p"/api/users/me")
      user_id = json_response(conn, 200)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-csrf-token", employee.csrf_token)
        |> put_req_header("authorization", "Bearer #{employee.token}")
      full_name = Faker.Person.name()

      conn = put(conn, ~p"/api/users/#{user_id}", %{username: full_name, email: "manager@epitech.eu"})
      assert json_response(conn, 400)["error"] == "user.update_failed"
    end

    test "with username and email", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)
      conn = get(conn, ~p"/api/users/me")
      user_id = json_response(conn, 200)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-csrf-token", employee.csrf_token)
        |> put_req_header("authorization", "Bearer #{employee.token}")
      full_name = Faker.Person.name()
      email = Faker.Internet.email()

      conn = put(conn, ~p"/api/users/#{user_id}", %{username: full_name, email: email})
      assert json_response(conn, 200)["username"] == full_name
      assert json_response(conn, 200)["email"] == email
    end
  end

  describe "delete user" do
    test "with unauthorized role", %{conn: conn, employee: employee} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{employee.token}")
        |> put_req_header("x-csrf-token", employee.csrf_token)

      conn = delete(conn, ~p"/api/users/0")
      assert json_response(conn, 403)["error"] == "user.role.not_authorized"
    end

    test "with bad user id", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = delete(conn, ~p"/api/users/0")
      assert json_response(conn, 404)["error"] == "user.not_found"
    end

    test "with user id", %{conn: conn, manager: manager} do
      conn = conn
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = post(
        conn,
        ~p"/api/users", %{
          username: Faker.Person.name(),
          email: Faker.Internet.email(),
          password: "azertyuiop"
        }
      )
      user_id = json_response(conn, 201)["id"]

      conn = build_conn()
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer #{manager.token}")
        |> put_req_header("x-csrf-token", manager.csrf_token)

      conn = delete(conn, ~p"/api/users/#{user_id}")
      assert response(conn, 204)
    end
  end

  test "promote user with bad role", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/promote", %{role: "ROLE_TEST"})
    assert json_response(conn, 400)["error"] == "user.form.invalid_role"
  end

  test "promote user", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/promote", %{role: "ROLE_MANAGER"})
    assert json_response(conn, 200) != nil
  end

  test "promote user with existing role", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/promote", %{role: "ROLE_MANAGER"})
    assert json_response(conn, 200) != nil

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/promote", %{role: "ROLE_MANAGER"})
    assert json_response(conn, 400)["error"] == "user.role_already_exists"
  end

  test "demote user with bad role", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/demote", %{role: "ROLE_TEST"})
    assert json_response(conn, 400)["error"] == "user.form.invalid_role"
  end

  test "demote user", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")
    put(conn, ~p"/api/users/#{user["id"]}/promote", %{role: "ROLE_MANAGER"})

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/demote", %{role: "ROLE_MANAGER"})
    assert json_response(conn, 200) != nil
  end

  test "demote user without role", %{conn: conn, employee: employee, supermanager: supermanager} do
    conn = conn
      |> put_req_header("authorization", "Bearer #{employee.token}")
      |> put_req_header("x-csrf-token", employee.csrf_token)
    conn = get(conn, ~p"/api/users/me")
    user = json_response(conn, 200)

    conn = build_conn()
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-csrf-token", supermanager.csrf_token)
      |> put_req_header("authorization", "Bearer #{supermanager.token}")

    conn = put(conn, ~p"/api/users/#{user["id"]}/demote", %{role: "ROLE_MANAGER"})
    assert json_response(conn, 400)["error"] == "user.role_not_found"
  end
end
