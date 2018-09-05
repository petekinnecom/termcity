defmodule TcCache.Repo.Migrations.CreateBuilds do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :tc_id, :integer
      add :tc_branch_name, :string
      add :tc_build_type_id, :string
      add :tc_number, :string
      add :tc_state, :string
      add :tc_status, :string
      add :tc_web_url, :string
      add :tc_failed_to_start, :boolean

      timestamps()
    end

    create index("builds", [:tc_id], unique: true)
    create index("builds", [:tc_branch_name])
    create index("builds", [:tc_number])
  end
end
