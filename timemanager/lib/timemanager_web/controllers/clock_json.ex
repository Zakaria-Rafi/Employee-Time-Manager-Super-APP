defmodule TimemanagerWeb.ClockJSON do
  alias Timemanager.Clocks.Clock

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end

  @doc """
  Renders a single clock.
  """
  def show(%{clock: clock}) do
    data(clock)
  end

  defp data(%Clock{} = clock) do
    %{
      id: clock.id,
      time: clock.time,
      status: clock.status,
      to_check: clock.to_check,
      created_at: clock.created_at
    }
  end
end
