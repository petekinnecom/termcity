defmodule TcCache.Sync.Scheduler do
  use GenServer
  alias Scheduler
  require Logger

  def start_link(jobs) do
    GenServer.start_link(__MODULE__, jobs)
  end

  def init(jobs) do
    if enabled?() do
      schedule(jobs)
      {:ok, nil}
    else
      :ignore
    end
  end

  def handle_info(job = {mod, fun, args, _delay_ms}, state) do
    Logger.info("Triggering job: #{inspect(job)}")
    spawn(fn -> apply(mod, fun, args) end)
    schedule([job])
    {:noreply, state}
  end

  defp schedule([head | tail]) do
    schedule(head)
    schedule(tail)
  end

  defp schedule(job = {_mod, _fun, _args, delay_ms}) do
    Logger.info("Scheduling job: #{inspect(job)}")
    Process.send_after(self(), job, delay_ms)
  end

  defp schedule([]), do: true

  defp enabled?() do
    Application.get_env(:tc_cache, __MODULE__)[:enabled]
  end
end
