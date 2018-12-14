defmodule TcCache.Circle.Store.Build do
  use Ecto.Schema
  import Ecto.Changeset

  schema "circle_builds" do
    field(:cir_branch, :string)
    field(:cir_vcs_revision, :string)
    field(:cir_build_num, :integer)
    field(:cir_job_name, :string)
    field(:cir_status, :string)
    field(:cir_build_url, :string)
    field(:cir_reponame, :string)
    timestamps()
  end

  @doc false
  def changeset(build, attrs) do
    build
    |> cast(attrs, [
      :cir_branch,
      :cir_vcs_revision,
      :cir_build_num,
      :cir_job_name,
      :cir_status,
      :cir_build_url,
      :cir_reponame,
    ])
    |> validate_required([
      :cir_branch,
      :cir_vcs_revision,
      :cir_build_num,
      :cir_job_name,
      :cir_status,
      :cir_build_url,
      :cir_reponame,
    ])
  end
end
