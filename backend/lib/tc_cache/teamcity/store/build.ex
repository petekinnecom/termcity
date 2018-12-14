defmodule TcCache.Teamcity.Store.Build do
  use Ecto.Schema
  import Ecto.Changeset

  schema "builds" do
    field(:tc_branch_name, :string)
    field(:tc_build_type_id, :string)
    field(:tc_id, :integer)
    field(:tc_number, :string)
    field(:tc_state, :string)
    field(:tc_status, :string)
    field(:tc_web_url, :string)
    field(:tc_failed_to_start, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(build, attrs) do
    build
    |> cast(attrs, [
      :tc_id,
      :tc_branch_name,
      :tc_build_type_id,
      :tc_number,
      :tc_state,
      :tc_status,
      :tc_web_url
    ])
    |> validate_required([
      :tc_id,
      :tc_branch_name,
      :tc_build_type_id,
      :tc_number,
      :tc_state,
      :tc_status,
      :tc_web_url
    ])
  end
end
