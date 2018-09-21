defmodule TcCache.Sync do
  require Logger

  alias TcCache.Source
  alias TcCache.Sync
  alias TcCache.Store
  @expiration_seconds -60 * 60 * 24 * 7
  @sync_builds_since_seconds -60 * 20

  def sync_build_states do
    Sync.sync_builds(%{state: "running"})
    Sync.sync_builds(%{state: "finished"})
    Sync.sync_builds(%{state: "queued"})
  end

  def sync_builds(locators) do
    Logger.info("#{__MODULE__}.sync_builds triggered with #{inspect(locators)}")

    default_since =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(@sync_builds_since_seconds, :second)

    {:ok, builds} =
      locators
      |> Enum.into(%{since: default_since})
      |> Source.fetch_builds()

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

  def sync_build_types() do
    Logger.info("#{__MODULE__}.sync_build_types triggered")
    {:ok, build_types} = Source.fetch_build_types()

    build_types
    |> Enum.map(&extract_build_type_keys/1)
    |> Store.upsert_build_types()

    Logger.info("#{__MODULE__}.sync_build_types synced #{length(build_types)} build_types")
  end

  defp extract_build_keys(tc_build) do
    %{
      tc_branch_name: tc_build["branchName"],
      tc_build_type_id: tc_build["buildTypeId"],
      tc_id: tc_build["id"],
      tc_number: tc_build["number"],
      tc_state: tc_build["state"],
      tc_status: tc_build["status"],
      tc_web_url: tc_build["webUrl"],
      tc_failed_to_start: tc_build["failedToStart"]
    }
  end

  defp extract_build_type_keys(tc_build_type) do
    %{
      tc_id: tc_build_type["id"],
      tc_name: tc_build_type["name"],
      tc_project_id: tc_build_type["projectId"],
      tc_project_name: tc_build_type["projectName"]
    }
  end
end
