defmodule TimemanagerWeb.SessionControllerTest do
  use TimemanagerWeb.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")
    {:ok, conn: conn}
  end

  describe "login" do
    setup %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{email: "employee@epitech.eu", password: "azertyuiop"})
      token = json_response(conn, 200)["token"]
      csrf_token = json_response(conn, 200)["csrf_token"]
      {:ok, token: token, csrf_token: csrf_token}
    end

    test "test login without email and password", %{conn: conn} do
      conn = post(conn, ~p"/api/login")
      assert json_response(conn, 400)["error"] == "auth.required_email_and_password"
    end

    test "test login without email and with password", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{email: "", password: "azertyuiop"})
      assert json_response(conn, 400)["error"] == "auth.form.empty_email"
    end

    test "test login with email and without password", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{email: "employee@epitech.eu", password: ""})
      assert json_response(conn, 400)["error"] == "auth.form.empty_password"
    end

    test "test login with bad email and password", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{email: "employeee@epitech.eu", password: "password"})
      assert json_response(conn, 400)["error"] == "auth.invalid_credentials"
    end

    test "test login with email and password", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{email: "employee@epitech.eu", password: "azertyuiop"})
      assert json_response(conn, 200)["token"] != nil
    end

    test "test logout with invalid token", %{conn: conn} do
      conn |> put_req_header("authorization", "Bearer azerty")
      conn = delete(conn, ~p"/api/logout")
      assert json_response(conn, 401)["error"] == "auth.invalid_token"
    end

    test "test logout with valid token", %{conn: conn, token: token, csrf_token: csrf_token} do
      conn = put_req_header(conn, "authorization", "Bearer #{token}") |> put_req_header("x-csrf-token", csrf_token)
      conn = delete(conn, ~p"/api/logout")
      assert response(conn, 204)
    end
  end
end
