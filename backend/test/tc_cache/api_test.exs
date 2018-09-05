defmodule TcCache.ApiTest do
  use ExUnit.Case
  alias TcCache.Api

  test "build_info marks builds queued and" do
    build_info = fn _, _, _ ->
      [
        %{
          id: 1,
          sha: "gitsha",
          status: "FAILURE",
          state: "finished",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name",
          failed_to_start: false
        },
        %{
          id: 2,
          sha: nil,
          status: nil,
          state: "queued",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name",
          failed_to_start: false
        },
        %{
          id: 3,
          sha: nil,
          status: nil,
          state: "queued",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name",
          failed_to_start: false
        },
        %{
          id: 4,
          sha: nil,
          status: nil,
          state: "queued",
          web_url: "web_url",
          build_type: "build_type_2",
          project_name: "project_name",
          failed_to_start: false
        }
      ]
    end

    expected = [
      %{
        id: 1,
        sha: "gitsha",
        status: "FAILURE",
        state: "finished",
        web_url: "web_url",
        build_type: "build_type",
        project_name: "project_name",
        failed_to_start: false,
        re_enqueued: true
      },
      %{
        id: 4,
        sha: nil,
        status: nil,
        state: "queued",
        web_url: "web_url",
        build_type: "build_type_2",
        project_name: "project_name",
        failed_to_start: false,
        re_enqueued: false
      }
    ]

    assert expected == Api.build_info("project_id", "branch", "revision", build_info)
  end
end
