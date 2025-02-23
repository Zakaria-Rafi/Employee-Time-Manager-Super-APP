defmodule TimemanagerWeb.WorkingTimeJSON do
  alias Timemanager.Workingtimes.WorkingTime

  @doc """
  Renders a list of workingtimes.
  """
  def index(%{workingtimes: workingtimes, started_at: started_at, ended_at: ended_at}) do
    %{
      started_at: started_at,
      ended_at: ended_at,
      items: for(working_time <- workingtimes.items, do: data(working_time)),
      total_count: workingtimes.total_count,
      total_pages: workingtimes.total_pages,
      current_page: workingtimes.current_page,
      next_page: workingtimes.next_page,
      prev_page: workingtimes.prev_page
    }
  end

  @doc """
  Renders a single working_time.
  """
  def show(%{working_time: working_time}) do
    data(working_time)
  end

  @doc """
  Renders a working_time.
  """
  def clocks(%{workingtimes: workingtimes, started_at: started_at, ended_at: ended_at}) do
    %{
      started_at: started_at,
      ended_at: ended_at,
      items: for working_time <- workingtimes do
        total_clocked_time =
          working_time.clocks
          |> Enum.chunk_every(2, 2, :discard) # Prendre les paires (start, end)
          |> Enum.reduce(0, fn [start_clock, end_clock], acc ->
            if start_clock.status == true and end_clock.status == false do
              DateTime.diff(end_clock.time, start_clock.time, :second) + acc
            else
              acc
            end
          end)

        %{
          id: working_time.id,
          start: working_time.start,
          end: working_time.end,
          created_at: working_time.created_at,
          updated_at: working_time.updated_at,
          clocks: (for clock <- working_time.clocks, do: %{
            id: clock.id,
            time: clock.time,
            status: clock.status,
            to_check: clock.to_check,
            created_at: clock.created_at
          }),
          total_worked_time: DateTime.diff(working_time.end, working_time.start, :second),
          total_clocked_time: total_clocked_time
        }
      end
    }
  end

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end

  defp data(%WorkingTime{} = working_time) do
    %{
      id: working_time.id,
      start: working_time.start,
      end: working_time.end,
      user: working_time.user_id,
      created_at: working_time.created_at,
      updated_at: working_time.updated_at,
      total_worked_time: DateTime.diff(working_time.end, working_time.start, :second)
    }
  end
end
