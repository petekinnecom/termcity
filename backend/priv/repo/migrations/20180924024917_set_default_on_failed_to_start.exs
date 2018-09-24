defmodule TcCache.Repo.Migrations.SetDefaultOnFailedToStart do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      modify :tc_failed_to_start, :boolean, default: false
    end

  end
end
