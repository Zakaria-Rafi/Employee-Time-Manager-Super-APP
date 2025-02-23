defmodule Timemanager.Workingtimes do
  import Ecto.Query, warn: false
  alias Timemanager.Repo

  alias Timemanager.Workingtimes.WorkingTime
  alias Timemanager.Clocks.Clock

  @doc """
  Returns the list of workingtimes by user and date.
  """
  def list_workingtimes_by_date(user_id, started_at, ended_at, page, page_size) do
    total_count_query =
      from(w in WorkingTime,
        where: w.user_id == ^user_id
      )

    query = from(w in WorkingTime,
      where: w.user_id == ^user_id,
      select: w,
      order_by: [asc: w.start],
      limit: ^page_size,
      offset: (^page - 1) * ^page_size
    )

    total_count_query =
      cond do
        is_nil(started_at) and is_nil(ended_at) ->
          total_count_query

        is_nil(started_at) and not is_nil(ended_at) ->
          from(w in total_count_query, where: w.end <= ^ended_at)

        not is_nil(started_at) and is_nil(ended_at) ->
          from(w in total_count_query, where: w.start >= ^started_at)

        not is_nil(started_at) and not is_nil(ended_at) ->
          from(w in total_count_query, where: w.start >= ^started_at and w.end <= ^ended_at)
      end

    query =
      cond do
        is_nil(started_at) and is_nil(ended_at) ->
          query

        is_nil(started_at) and not is_nil(ended_at) ->
          from(w in query, where: w.end <= ^ended_at)

        not is_nil(started_at) and is_nil(ended_at) ->
          from(w in query, where: w.start >= ^started_at)

        not is_nil(started_at) and not is_nil(ended_at) ->
          from(w in query, where: w.start >= ^started_at and w.end <= ^ended_at)
      end

    total_count =
      total_count_query
      |> select([w], count(w.id))
      |> Repo.one() || 0
    result = Repo.all(query)
    total_pages = div(total_count, page_size) + rem(total_count, page_size)
    %{
      items: result,
      total_count: total_count,
      total_pages: total_pages,
      current_page: page,
      next_page: page < total_pages,
      prev_page: page > 1
    }
  end

  @doc """
  Gets a single working_time by user and working_time id.
  """
  def get_working_time_by_user(user_id, working_time_id) do
    query = from w in WorkingTime, where: w.user_id == ^user_id and w.id == ^working_time_id, select: w
    Repo.one(query)
  end

  @doc """
  Retrieves a user by ID.
  """
  def get_working_time_by_id(id) do
    query = from w in WorkingTime, where: w.id == ^id, select: w
    Repo.one(query)
  end

  @doc """
  Creates a working_time.
  """
  def create_working_time(attrs \\ %{}) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a working_time.
  """
  def update_working_time(%WorkingTime{} = working_time, attrs \\ %{}) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a working_time.
  """
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  @doc """
  Returns the list of workingtimes by user and date.
  """
  def get_clocks(user_id, started_at, ended_at) do
    working_time_query = from(w in WorkingTime,
      where: w.user_id == ^user_id,
      select: w
    )

    working_time_query =
      cond do
        is_nil(started_at) and is_nil(ended_at) ->
          working_time_query

        is_nil(started_at) and not is_nil(ended_at) ->
          from(w in working_time_query, where: w.end <= ^ended_at)

        not is_nil(started_at) and is_nil(ended_at) ->
          from(w in working_time_query, where: w.start >= ^started_at)

        not is_nil(started_at) and not is_nil(ended_at) ->
          from(w in working_time_query, where: w.start >= ^started_at and w.end <= ^ended_at)
      end

    working_times = Repo.all(working_time_query)

    formatted_results = Enum.map(working_times, fn working_time ->
      start_date = NaiveDateTime.to_date(working_time.start)
      end_date = NaiveDateTime.to_date(working_time.end)

      start_of_day = NaiveDateTime.new!(start_date, ~T[00:00:00])
      end_of_day = NaiveDateTime.new!(end_date, ~T[23:59:59])

      clocks_query = from(c in Clock,
        where: c.user_id == ^user_id and c.time >= ^start_of_day and c.time <= ^end_of_day,
        select: c
      )

      clocks = Repo.all(clocks_query)

      %{
        id: working_time.id,
        start: working_time.start,
        end: working_time.end,
        created_at: working_time.created_at,
        updated_at: working_time.updated_at,
        clocks: Enum.map(clocks, fn clock ->
          %{
            id: clock.id,
            time: clock.time,
            status: clock.status,
            to_check: clock.to_check,
            created_at: clock.created_at
          }
        end)
      }
    end)

    formatted_results
  end
end
