defmodule TcCache.Api do
  # currently we just hit github
  def authenticate(token, get \\ &HTTPoison.get!/3) do
    TcCache.Authentication.authenticate(token, get)
  end

  def build_info(project_id, branch, revision, build_info \\ &TcCache.Teamcity.Store.build_info/3) do
    builds = build_info.(project_id, branch, revision)

    links = %{overview: overview_link(project_id, branch)}

    builds_data =
      builds
      |> Enum.map(fn b -> b.build_type end)
      |> Enum.uniq()
      |> Enum.map(fn bt -> build_result(bt, builds) end)
      |> Enum.sort_by(fn b -> b.id end)

    %{builds: builds_data, links: links}
  end

  defp build_result(build_type, builds) do
    finished_build =
      Enum.find(builds, fn b ->
        b.build_type == build_type && b.sha != nil
      end)

    queued_builds =
      Enum.filter(builds, fn b ->
        b.build_type == build_type && b.sha == nil
      end)

    reduce_builds(finished_build, queued_builds)
  end

  defp reduce_builds(nil, queueds) do
    Enum.into(%{re_enqueued: false}, List.last(queueds))
  end

  defp reduce_builds(finished = %{}, []) do
    Enum.into(%{re_enqueued: false}, finished)
  end

  defp reduce_builds(finished, _queueds) do
    Enum.into(%{re_enqueued: true}, finished)
  end

  defp overview_link(project_id, "master"), do: overview_link(project_id, "%3Cdefault%3E")

  defp overview_link(project_id, branch) do
    Application.get_env(:tc_cache, TcCache.Teamcity.Source)[:host]
    |> URI.merge("/project.html?projectId=#{project_id}&branch=#{branch}")
    |> URI.to_string()
  end
end
