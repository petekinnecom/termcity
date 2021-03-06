defmodule TcCache.ApiTest do
  use ExUnit.Case
  alias TcCache.Api

  test "authenticate: valid token, org member" do
    Cachex.clear(:tc)
    headers = [{"Authorization", "token token-value"}]

    body = [
      %{"login" => "something else"},
      %{"login" => "myOrg"}
    ]

    get = dummy_get(200, headers, body)

    assert {:ok, true} == Api.authenticate("token-value", get)
  end

  test "authenticate: valid token, not org member" do
    Cachex.clear(:tc)
    headers = [{"Authorization", "token token-value"}]

    body = [
      %{"login" => "something else"},
      %{"login" => "something else 2"}
    ]

    get = dummy_get(200, headers, body)
    assert {:error, :not_member} == Api.authenticate("token-value", get)
  end

  test "authenticate: invalid token" do
    Cachex.clear(:tc)
    headers = [{"Authorization", "token token-value"}]

    get = dummy_get(401, headers, [])
    assert {:error, :token_failure} == Api.authenticate("token-value", get)
  end

  test "build_info marks builds queued" do
    build_info = fn _, _, _, _ ->
      [
        %{
          id: 1,
          sha: "gitsha",
          status: "failed",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name"
        },
        %{
          id: 2,
          sha: nil,
          status: "queued",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name"
        },
        %{
          id: 3,
          sha: nil,
          status: "queued",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name"
        },
        %{
          id: 4,
          sha: nil,
          status: "queued",
          web_url: "web_url",
          build_type: "build_type_2",
          project_name: "project_name",
        }
      ]
    end

    expected = %{
      links: %{
        teamcity_overview: "https://example.com/project.html?projectId=project_id&branch=branch",
        circle_overview: "https://circleci.com/myorg/workflows/reponame/tree/branch"
      },
      builds: [
        %{
          id: 1,
          sha: "gitsha",
          status: "failed",
          web_url: "web_url",
          build_type: "build_type",
          project_name: "project_name",
          re_enqueued: true
        },
        %{
          id: 4,
          sha: nil,
          status: "queued",
          web_url: "web_url",
          build_type: "build_type_2",
          project_name: "project_name",
          re_enqueued: false
        }
      ]
    }

    assert expected == Api.build_info("project_id", "reponame", "branch", "revision", build_info)
  end

  defp dummy_get(code, headers, body) do
    fn _, h, o ->
      assert [] == headers -- h
      assert [] == o
      %{
        status_code: code,
        body: Poison.encode!(body)
      }
    end
  end

end
