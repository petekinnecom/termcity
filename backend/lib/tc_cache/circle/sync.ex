defmodule Parallel do
end

defmodule TcCache.Circle.Sync do
  require Logger

  alias TcCache.Circle.Source
  alias TcCache.Circle.Store
  @expiration_seconds -60 * 60 * 24 * 7

  def sync_all_builds do
    pmap((0..10), fn(i) -> sync_builds(%{"offset" => 100*i}) end)
  end

  def pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end


  def sync_builds(filters \\ %{}) do
    Logger.info("#{__MODULE__}.sync_builds triggered with #{inspect(filters)}")

    {:ok, builds} = Source.fetch_builds(filters)

    builds
    |> Enum.map(&extract_build_keys/1)
    |> Store.upsert_builds()

    Logger.info("#{__MODULE__}.sync_builds synced #{length(builds)} builds")
  end

  def expire_builds(now \\ NaiveDateTime.utc_now()) do
    Logger.info("#{__MODULE__}.expire_builds triggered")

    now
    |> NaiveDateTime.add(@expiration_seconds)
    |> Store.expire_builds()

    Logger.info("#{__MODULE__}.expire_builds finished")
  end

  defp extract_build_keys(build) do
    %{
      cir_branch: build["branch"],
      cir_vcs_revision: build["vcs_revision"],
      cir_build_num: build["build_num"],
      cir_job_name: build["workflows"]["job_name"],
      cir_status: build["status"],
      cir_build_url: build["build_url"],
      cir_reponame: build["reponame"]
    }
  end
end
