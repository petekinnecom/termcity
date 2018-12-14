defmodule TcCache.Circle.Source do
  require Logger
  alias TcCache.Circle.Source.Builds

  @host "https://circleci.appf.io/api/v1.1/"

  @default_filters %{
    "limit" => 100,
    "shallow" => true
  }

  def fetch_builds(filters \\ %{}, get \\&HTTPoison.get!/3) do
    params = @default_filters
    |> Map.merge(filters)
    |> Map.merge(%{"circle-token" => token()})

    get.(
      join(@host, "recent-builds"),
      [{"Accept", "application/json"}],
      recv_timeout: 20_000,
      params: params
    )
    |> Builds.process()
  end

  defp join(host, path) do
    URI.merge(host, path) |> URI.to_string()
  end

  defp token do
    Application.get_env(:tc_cache, TcCache.Circle.Source)[:token]
  end
end
