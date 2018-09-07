defmodule TcCache.Api do
  # currently we just hit github
  def authenticate(token) do
    if Cachex.exists?(:tc, token) do
      {:ok, true}
    else
      case TcCache.Source.authenticate(token) do
        {:ok, _} -> {:ok, Cachex.put!(:tc, token, true)}
        {:error, msg} -> {:error, msg}
      end
    end
  end

  def build_info(project_id, branch, revision, build_info \\ &TcCache.Store.build_info/3) do
    builds = build_info.(project_id, branch, revision)

    builds
    |> Enum.map(fn b -> b.build_type end)
    |> Enum.uniq()
    |> Enum.map(fn bt -> build_result(bt, builds) end)
    |> Enum.sort_by(fn b -> b.id end)
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
end
