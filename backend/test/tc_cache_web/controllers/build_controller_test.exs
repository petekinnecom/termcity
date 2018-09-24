defmodule TcCacheWeb.BuildControllerTest do
  use TcCacheWeb.ConnCase

  defmodule DummyApi do
    def authenticate("valid_token"), do: {:ok, true}
    def authenticate("invalid_token"), do: {:error, :nope}

    def build_info(project_id, branch, revision),
      do: TcCache.Api.build_info(project_id, branch, revision)
  end

  test "GET builds?mybranch with auth", %{conn: conn} do
    TcCache.Store.upsert_builds([
      TcCache.Fixtures.Store.build_attrs(%{
        tc_id: 1,
        tc_build_type_id: "build_type_id_1",
        tc_number: "gitsha",
        tc_state: "running",
        tc_status: "SUCCESS",
        tc_web_url: "some tc_web_url"
      }),
      TcCache.Fixtures.Store.build_attrs(%{
        tc_id: 2,
        tc_build_type_id: "build_type_id_2",
        tc_number: "gitsha",
        tc_state: "running",
        tc_status: "SUCCESS",
        tc_web_url: "some tc_web_url"
      })
    ])

    TcCache.Store.upsert_build_types([
      TcCache.Fixtures.Store.build_type_attrs(%{
        tc_id: "build_type_id_1",
        tc_name: "build_type_name_1",
        tc_project_id: "project_id",
        tc_project_name: "project_name"
      }),
      TcCache.Fixtures.Store.build_type_attrs(%{
        tc_id: "build_type_id_2",
        tc_name: "build_type_name_2",
        tc_project_id: "project_id",
        tc_project_name: "project_name"
      })
    ])

    build_info =
      conn
      |> Plug.Conn.put_req_header("authorization", "valid_token")
      |> TcCacheWeb.BuildController.index(
        %{"project_id" => "project_id", "branch" => "myBranch"},
        DummyApi
      )
      |> json_response(200)

    expected = %{
      "links" => %{
        "overview" => "https://example.com/project.html?projectId=project_id&branch=myBranch"
      },
      "builds" => [
        %{
          "build_type" => "build_type_name_1",
          "id" => 1,
          "project_name" => "project_name",
          "sha" => "gitsha",
          "state" => "running",
          "status" => "SUCCESS",
          "web_url" => "some tc_web_url",
          "re_enqueued" => false
        },
        %{
          "build_type" => "build_type_name_2",
          "id" => 2,
          "project_name" => "project_name",
          "sha" => "gitsha",
          "state" => "running",
          "status" => "SUCCESS",
          "web_url" => "some tc_web_url",
          "re_enqueued" => false
        }
      ]
    }

    assert expected == build_info
  end

  test "GET /branch/myBranch no auth", %{conn: conn} do
    conn
    |> Plug.Conn.put_req_header("authorization", "invalid_token")
    |> TcCacheWeb.BuildController.index(
      %{"project_id" => "project_id", "branch" => "myBranch"},
      DummyApi
    )
    |> response(401)
  end
end
