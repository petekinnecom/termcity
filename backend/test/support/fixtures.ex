defmodule TcCache.Teamcity.Fixtures.Store do
  def build_type_attrs(id) when is_binary(id) do
    %{
      tc_id: "build_type_id_#{id}",
      tc_name: "build_type_name_#{id}",
      tc_project_id: "build_type_project_id_#{id}",
      tc_project_name: "build_type_project_name_#{id}"
    }
  end

  def build_type_attrs(attrs) do
    Enum.into(
      attrs,
      %{
        tc_id: "build_type_id",
        tc_name: "build_type_name",
        tc_project_id: "build_type_project_id",
        tc_project_name: "build_type_project_name"
      }
    )
  end

  def build_attrs(attrs = %{tc_id: _}) do
    Enum.into(
      attrs,
      %{
        tc_branch_name: "myBranch",
        tc_build_type_id: "build_type_id",
        tc_number: "gitsha",
        tc_state: "finished",
        tc_status: "SUCCESS",
        tc_web_url: "some tc_web_url"
      }
    )
  end
end
