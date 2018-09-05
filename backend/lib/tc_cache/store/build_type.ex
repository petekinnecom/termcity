defmodule TcCache.Store.BuildType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "build_types" do
    field(:tc_id, :string)
    field(:tc_name, :string)
    field(:tc_project_id, :string)
    field(:tc_project_name, :string)

    timestamps(usec: false)
  end

  @doc false
  def changeset(build_type, attrs) do
    build_type
    |> cast(attrs, [:tc_id, :tc_name, :tc_project_id, :tc_project_name])
    |> validate_required([:tc_id, :tc_name, :tc_project_id, :tc_project_name])
  end
end
