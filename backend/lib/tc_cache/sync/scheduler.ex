defmodule TcCache.Sync.Scheduler do
  use GenServer
  alias Scheduler

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

  def handle_info({mod, fun, delay_ms}, state) do
    spawn(fn -> apply(mod, fun, []) end)
    schedule([{mod, fun, delay_ms}])
    {:noreply, state}
  end

  defp schedule([head | tail]) do
    schedule(head)
    schedule(tail)
  end

  defp schedule(job = {_mod, _fun, delay_ms}) do
    Process.send_after(self(), job, delay_ms)
  end

  defp schedule([]), do: true

  defp enabled?() do
    Application.get_env(:tc_cache, __MODULE__)[:enabled]
  end
end
