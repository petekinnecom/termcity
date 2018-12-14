defmodule TcCache.Circle.Store do
  import Ecto.Query, warn: false

  alias TcCache.Repo
  alias TcCache.Circle.Store.Build

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
