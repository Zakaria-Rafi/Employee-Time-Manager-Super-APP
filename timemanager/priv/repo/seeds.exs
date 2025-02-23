# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Timemanager.Repo.insert!(%Timemanager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Timemanager.Users
alias Timemanager.Workingtimes
alias Timemanager.Clocks
alias Timemanager.Teams

Users.create_user(
  %{
    username: "supermanager",
    email: "supermanager@epitech.eu",
    password: Bcrypt.Base.hash_password("azertyuiop", Bcrypt.Base.gen_salt(12, true)),
    roles: ["ROLE_SUPERMANAGER"]
  }
)

supermanager = Users.get_user_by_query("supermanager@epitech.eu", "supermanager")

Users.create_user(
  %{
    username: "manager",
    email: "manager@epitech.eu",
    password: Bcrypt.Base.hash_password("azertyuiop", Bcrypt.Base.gen_salt(12, true)),
    roles: ["ROLE_MANAGER"]
  }
)

manager = Users.get_user_by_query("manager@epitech.eu", "manager")

for i <- 1..10 do
  current_date = if i == 1 do
    DateTime.utc_now()
  else
    DateTime.utc_now() |> DateTime.add(i, :day)
  end

  start_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[09:00:00])
    |> elem(1)

  end_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[17:00:00])
    |> elem(1)

  Workingtimes.create_working_time(
    %{
      user_id: manager.id,
      start: start_date,
      end: end_date
    }
  )
end

Users.create_user(
  %{
    username: "employee",
    email: "employee@epitech.eu",
    password: Bcrypt.Base.hash_password("azertyuiop", Bcrypt.Base.gen_salt(12, true)),
  }
)

employee = Users.get_user_by_query("employee@epitech.eu", "employee")

for i <- 1..10 do
  current_date = if i == 1 do
    DateTime.utc_now()
  else
    DateTime.utc_now() |> DateTime.add(i, :day)
  end

  start_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[09:00:00])
    |> elem(1)

  end_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[17:00:00])
    |> elem(1)

  Workingtimes.create_working_time(
    %{
      user_id: employee.id,
      start: start_date,
      end: end_date
    }
  )
end

for i <- 1..3 do
  current_date = if i == 1 do
    DateTime.utc_now()
  else
    DateTime.utc_now() |> DateTime.add(i, :day)
  end

  start_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[09:00:00])
    |> elem(1)

  Clocks.create_clock(
    %{
      user_id: employee.id,
      status: true,
      time: start_date
    }
  )

  end_date =
    current_date
    |> DateTime.to_date()
    |> DateTime.new(~T[17:00:00])
    |> elem(1)

  Clocks.create_clock(
      %{
        user_id: employee.id,
        status: false,
        time: end_date
      }
    )
end

for i <- 1..3 do
  case Teams.create_team(%{name: "team #{i}"}) do
    {:ok, %Timemanager.Teams.Team{} = team} ->
      Teams.add_user_to_team(Teams.get_team_by_id(team.id, true), supermanager)
      Teams.add_user_to_team(Teams.get_team_by_id(team.id, true), manager)
      Teams.add_user_to_team(Teams.get_team_by_id(team.id, true), employee)
    _error -> IO.puts("Error while creating team")
  end
end
