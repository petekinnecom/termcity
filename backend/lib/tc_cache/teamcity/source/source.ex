defmodule TcCache.Teamcity.Source do
  alias TcCache.Teamcity.Source
  require Logger

  @build_types_path "app/rest/buildTypes"

  @default_locators %{
    count: 5000,
    branch: "(default:any)",
    failedToStart: "any",
    defaultFilter: false
  }

  defmodule Config do
    @keys [:host, :username, :password]
    @enforce_keys @keys
    defstruct @keys
  end

  def fetch_builds(psuedo_locators, get \\ &HTTPoison.get!/3) do
    cfg = config()
    locators = build_locators(psuedo_locators)
    Logger.info("fetching builds with locators: #{inspect(locators)}")

    get.(
      join(cfg.host, builds_path(cfg.host, locators)),
      [{"Accept", "application/json"}],
      hackney: [basic_auth: {cfg.username, cfg.password}],
      recv_timeout: 20_000
    )
    |> Source.Builds.process()
  end

  def fetch_build_types(get \\ &HTTPoison.get!/3) do
    cfg = config()

    get.(
      join(cfg.host, @build_types_path),
      [{"Accept", "application/json"}],
      hackney: [basic_auth: {cfg.username, cfg.password}],
      recv_timeout: 20_000
    )
    |> Source.BuildTypes.process()
  end

  @doc """
    Builds a locator struct for fetching builds.

    Convenience keys:
      since: NaiveDateTime (can only be specified if 'state:' is passed)

    ## Examples

        iex> TcCache.Teamcity.Source.build_locators(%{state: "finished", since: ~N[2000-01-01 23:00:07], count: 300, lookupLimit: 5000})
        %{
          branch: "(default:any)",
          count: 300,
          defaultFilter: false,
          failedToStart: "any",
          state: "finished",
          finishDate: "(date:20000101T230007%2B0000,condition:after)",
          lookupLimit: 5000,
        }

        iex> TcCache.Teamcity.Source.build_locators(%{count: 300})
        %{
          branch: "(default:any)",
          count: 300,
          defaultFilter: false,
          failedToStart: "any"
        }

  """
  def build_locators(locators = %{state: "queued", since: since}) do
    locators
    |> Map.put(:queuedDate, ndt_to_tc(since))
    |> Map.delete(:since)
    |> build_locators()
  end

  def build_locators(locators = %{state: "finished", since: since}) do
    locators
    |> Map.put(:finishDate, ndt_to_tc(since))
    |> Map.delete(:since)
    |> build_locators()
  end

  def build_locators(locators = %{state: "running", since: since}) do
    locators
    |> Map.put(:startDate, ndt_to_tc(since))
    |> Map.delete(:since)
    |> build_locators()
  end

  def build_locators(%{since: _since}) do
    raise "Invalid locators: can't pass 'since' key without 'state' key"
  end

  def build_locators(l), do: Enum.into(l, @default_locators)

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
    %TcCache.Teamcity.Source.Config{
      host: Application.get_env(:tc_cache, TcCache.Teamcity.Source)[:host],
      username: Application.get_env(:tc_cache, TcCache.Teamcity.Source)[:username],
      password: Application.get_env(:tc_cache, TcCache.Teamcity.Source)[:password]
    }
  end

  defp ndt_to_tc(ndt = %NaiveDateTime{}) do
    ndt
    |> NaiveDateTime.to_iso8601()
    # don't use NaiveDateTime.truncate because it doesn't work on older elixir version
    |> String.replace(~r[\.\d+], "")
    |> String.replace("-", "")
    |> String.replace(":", "")
    |> append_tz()
    |> to_tc_date_condition()
  end

  defp append_tz(s), do: "#{s}%2B0000"
  defp to_tc_date_condition(s), do: "(date:#{s},condition:after)"
end
