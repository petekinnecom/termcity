defmodule TcCache.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(TcCache.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TcCacheWeb.Endpoint, []),
      supervisor(Task.Supervisor, [[name: TcCache.TaskSupervisor]]),
      worker(TcCache.Sync.Scheduler, [
        [
          {TcCache.Sync, :sync_builds, 60 * 1_000},
          {TcCache.Sync, :sync_build_types, 60 * 60 * 1_000},
          {TcCache.Sync, :expire_builds, 60 * 60 * 24 * 1_000}
        ]
      ])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TcCache.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TcCacheWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
