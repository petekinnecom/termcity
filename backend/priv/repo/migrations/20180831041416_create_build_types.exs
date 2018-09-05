defmodule TcCache.Repo.Migrations.CreateBuildTypes do
  use Ecto.Migration

  def change do
    create table(:build_types) do
      add :tc_id, :string
      add :tc_name, :string
      add :tc_project_id, :string
      add :tc_project_name, :string

      timestamps()
    end

    create index("build_types", [:tc_id], unique: true)
  end
end
