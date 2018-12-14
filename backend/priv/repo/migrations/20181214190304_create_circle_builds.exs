defmodule TcCache.Repo.Migrations.CreateCircleBuilds do
  use Ecto.Migration

  def change do
    create table(:circle_builds) do
      add :cir_branch, :string
      add :cir_vcs_revision, :string

      add :cir_build_num, :integer
      add :cir_job_name, :string
      add :cir_reponame, :string

      add :cir_status, :string
      add :cir_build_url, :string

      timestamps()
    end

    create index("circle_builds", [:cir_build_num], unique: true)
    create index("circle_builds", [:cir_branch])
    create index("circle_builds", [:cir_vcs_revision])
    create index("circle_builds", [:cir_reponame])
  end
end
