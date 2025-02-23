defmodule TimemanagerWeb.Router do
  use TimemanagerWeb, :router

  pipeline :browser do
    plug :accepts, ["json"]
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TimemanagerWeb.Plug.Authenticate
    plug TimemanagerWeb.Plug.CSRFProtection
  end

  scope "/api", TimemanagerWeb do
    pipe_through :api
    post "/login", SessionController, :login
  end

  scope "/api", TimemanagerWeb do
    pipe_through [:api, :authenticated]

    delete "/logout", SessionController, :logout

    get "/users", UserController, :index
    get "/users/me", UserController, :me
    get "/users/:userId", UserController, :show
    get "/users/:userId/teams", UserController, :teams
    post "/users", UserController, :create
    put "/users/:userId", UserController, :update
    put "/users/:userId/promote", UserController, :promote
    put "/users/:userId/demote", UserController, :demote
    delete "/users/:userId", UserController, :delete

    get "/workingtime/:userId", WorkingTimeController, :list_workingtimes_by_date
    get "/workingtime/:userId/clocks", WorkingTimeController, :get_clocks
    get "/workingtime/:userId/:id", WorkingTimeController, :show
    post "/workingtime/:userId", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete

    get "/clocks/:userId", ClockController, :show
    post "/clocks/:userId", ClockController, :create
    post "/clocks/:userId/offline", ClockController, :create_offline
    get "/clocks/:userId/clock/:clockId", ClockController, :show_offline
    put "/clocks/:userId/clock/:clockId", ClockController, :update_offline
    delete "/clocks/:userId/clock/:clockId", ClockController, :delete_offline

    get "/teams", TeamController, :get_all
    get "/teams/:teamId", TeamController, :get_team_by_id
    post "/teams", TeamController, :create
    put "/teams/:teamId", TeamController, :update
    put "/teams/:teamId/add/:userId", TeamController, :add_user
    delete "/teams/:teamId/remove/:userId", TeamController, :remove_user
    delete "/teams/:teamId", TeamController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:timemanager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TimemanagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
