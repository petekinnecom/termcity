defmodule TcCache.Circle.Store do
  import Ecto.Query, warn: false

  alias TcCache.Repo
  alias TcCache.Circle.Store.Build

  def build_info(reponame, branch_name, nil) do
    revisions =
      Repo.all(
        from(b in Build,
          select: b.cir_vcs_revision,
          where: b.cir_branch == ^branch_name,
          order_by: [desc: b.cir_build_num],
          limit: 1
        )
      )

    case revisions do
      [] -> []
      [revision] -> build_info_query(reponame, branch_name, revision)
    end
  end

  def build_info(reponame, branch_name, revision) do
    build_info_query(reponame, branch_name, revision)
  end

  def build_info_query(reponame, branch_name, revision) do
    Repo.all(
      from(b in Build,
        where: b.cir_branch == ^branch_name and b.cir_reponame == ^reponame and b.cir_vcs_revision == ^revision,
        order_by: [asc: b.cir_job_name],
        select: %{
          id: b.cir_build_num,
          build_type: b.cir_job_name,
          project_name: b.cir_reponame,
          sha: b.cir_vcs_revision,
          status: b.cir_status,
          web_url: b.cir_build_url,
        }
      )
    )
  end

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
