defmodule TcCache.Store do
  import Ecto.Query, warn: false
  alias TcCache.Repo

  alias TcCache.Store.BuildType
  alias TcCache.Store.Build

  def build_info(project_id, branch_name, nil) do
    build_numbers =
      Repo.all(
        from(b in Build,
          select: b.tc_number,
          where: b.tc_branch_name == ^branch_name and not is_nil(b.tc_number),
          order_by: [desc: b.id],
          limit: 1
        )
      )

    case build_numbers do
      [] -> build_info_query(project_id, branch_name, nil)
      [bn] -> build_info_query(project_id, branch_name, bn)
    end
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
          build_type: bt.tc_name,
          project_name: bt.tc_project_name
        }
      )
    )
  end

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
