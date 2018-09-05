defmodule TcCache.Source do
  alias TcCache.Source.Authentication
  alias TcCache.Source.BuildTypes
  alias TcCache.Source.Builds

  @github_org_path "https://api.github.com/user/orgs"
  @build_types_path "app/rest/buildTypes"

  defmodule Config do
    @keys [:host, :username, :password]
    @enforce_keys @keys
    defstruct @keys
  end

  def fetch_builds(count, get \\ &HTTPoison.get!/3) do
    locators = %{
      count: count,
      failedToStart: "any",
      defaultFilter: false,
      lookupLimit: count
    }

    cfg = config()

    get.(
      join(cfg.host, builds_path(cfg.host, locators)),
      [{"Accept", "application/json"}],
      hackney: [basic_auth: {cfg.username, cfg.password}],
      recv_timeout: 20_000
    )
    |> Builds.process()
  end

  def fetch_build_types(get \\ &HTTPoison.get!/3) do
    cfg = config()

    get.(
      join(cfg.host, @build_types_path),
      [{"Accept", "application/json"}],
      hackney: [basic_auth: {cfg.username, cfg.password}],
      recv_timeout: 20_000
    )
    |> BuildTypes.process()
  end

  def authenticate(token, get \\ &HTTPoison.get!/3) do
    get.(
      @github_org_path,
      [
        {"Accept", "application/json"},
        {"Authorization", "token #{token}"}
      ],
      []
    )
    |> Authentication.process()
  end

  defp join(host, path) do
    URI.merge(host, path) |> URI.to_string()
  end

  defp builds_path(host, locators) do
    locator =
      locators
      |> Enum.map(fn {k, v} -> "#{to_string(k)}:#{to_string(v)}" end)
      |> Enum.join(",")

    URI.merge(host, "app/rest/builds?locator=#{locator}")
  end

  defp config() do
    %TcCache.Source.Config{
      host: Application.get_env(:tc_cache, TcCache.Source)[:host],
      username: Application.get_env(:tc_cache, TcCache.Source)[:username],
      password: Application.get_env(:tc_cache, TcCache.Source)[:password]
    }
  end
end
