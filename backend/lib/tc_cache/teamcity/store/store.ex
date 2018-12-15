defmodule TcCache.Teamcity.Store do
  import Ecto.Query, warn: false
  alias TcCache.Repo

  alias TcCache.Teamcity.Store.BuildType
  alias TcCache.Teamcity.Store.Build

  def latest_revision(project_id, branch_name) do
    revisions =
      Repo.all(
        from(b in Build,
          select: b.tc_number,
          where: b.tc_branch_name == ^branch_name and not is_nil(b.tc_number),
          order_by: [desc: b.id],
          limit: 1
        )
      )

    case revisions do
      [] -> nil
      [rev] -> rev
    end
  end

  def build_info(project_id, branch_name, nil) do
    build_info_query(project_id, branch_name, latest_revision(project_id, branch_name))
  end

  def build_info(project_id, branch_name, revision) do
    build_info_query(project_id, branch_name, revision)
  end

  # if build_number is nil then we are only searching for queued builds
  def build_info_query(project_id, branch_name, build_number) do
    # this could be turned into a sub-query
    tc_ids =
      case build_number do
        nil ->
          []

        _ ->
          Repo.all(
            from(b in Build,
              where:
                b.tc_branch_name == ^branch_name and b.tc_number == ^build_number and
                  not is_nil(b.tc_number),
              right_join: bt in BuildType,
              where: bt.tc_id == b.tc_build_type_id and bt.tc_project_id == ^project_id,
              select: max(b.tc_id),
              group_by: bt.tc_id
            )
          )
      end

    queued_tc_ids =
      Repo.all(
        from(b in Build,
          where: b.tc_branch_name == ^branch_name and is_nil(b.tc_number),
          right_join: bt in BuildType,
          where: bt.tc_id == b.tc_build_type_id and bt.tc_project_id == ^project_id,
          select: max(b.tc_id),
          group_by: bt.tc_id
        )
      )

    all_ids = queued_tc_ids ++ tc_ids

    Repo.all(
      from(b in Build,
        where: b.tc_id in ^all_ids,
        join: bt in BuildType,
        where: bt.tc_id == b.tc_build_type_id,
        order_by: [asc: bt.tc_name],
        select: %{
          id: b.tc_id,
          sha: b.tc_number,
          status: b.tc_status,
          state: b.tc_state,
          web_url: b.tc_web_url,
          failed_to_start: b.tc_failed_to_start,
          build_type: bt.tc_name,
          project_name: bt.tc_project_name
        }
      )
    )
    |> Enum.map(&reduce_build/1)
  end

  defp reduce_build(db_build) do
    status = calc_status(
      db_build.state,
      db_build.status,
      db_build.failed_to_start
    )

    %{
      id: db_build.id,
      sha: db_build.sha,
      web_url: db_build.web_url,
      build_type: db_build.build_type,
      project_name: db_build.project_name,
    }
    |> Map.merge(%{status: status})
  end

  defp calc_status("queued", _, _), do: "queued"
  defp calc_status("running", "FAILURE", _), do: "failing"
  defp calc_status("running", "SUCCESS", _), do: "running"
  defp calc_status(_, _, true), do: "failstrt"
  defp calc_status(_, "FAILURE", nil), do: "failed"
  defp calc_status(_, "FAILURE", false), do: "failed"
  defp calc_status(_, _, nil), do: "success"
  defp calc_status(_, _, false), do: "success"

  def get_build_type!(id), do: Repo.get!(BuildType, id)

  def upsert_build_types(attrs, time \\ NaiveDateTime.utc_now()) do
    bulk_upsert(BuildType, attrs, time)
  end

  def get_build!(id), do: Repo.get!(Build, id)

  def upsert_builds(attrs, time \\ NaiveDateTime.utc_now()) do
    :ok =
      attrs
      |> Enum.chunk_every(100)
      |> Enum.each(fn chunk -> bulk_upsert(Build, chunk, time) end)

    {length(attrs), true}
  end

  def expire_builds(cutoff_time) do
    Repo.delete_all(from(b in Build, where: b.inserted_at < ^cutoff_time))
  end

  defp bulk_upsert(schema, attrs, time) do
    add_timestamps = bind_timestamps(time)
    timed_attrs = Enum.map(attrs, add_timestamps)
    Repo.insert_all(schema, timed_attrs, on_conflict: :replace_all)
  end

  defp bind_timestamps(time) do
    fn attrs ->
      Enum.into(%{inserted_at: time, updated_at: time}, attrs)
    end
  end
end
