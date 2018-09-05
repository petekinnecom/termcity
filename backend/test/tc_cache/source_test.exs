defmodule TcCache.SourceTest do
  use ExUnit.Case
  alias TcCache.Source

  test "authenticate: valid token, org member" do
    headers = [{"Authorization", "token token-value"}]

    body = [
      %{"login" => "something else"},
      %{"login" => "myOrg"}
    ]

    get = dummy_get(200, headers, body)

    assert {:ok, true} == Source.authenticate("token-value", get)
  end

  test "authenticate: valid token, not org member" do
    headers = [{"Authorization", "token token-value"}]

    body = [
      %{"login" => "something else"},
      %{"login" => "something else 2"}
    ]

    get = dummy_get(200, headers, body)
    assert {:error, :not_member} == Source.authenticate("token-value", get)
  end

  test "authenticate: invalid token" do
    headers = [{"Authorization", "token token-value"}]

    get = dummy_get(401, headers, [])
    assert {:error, :token_failure} == Source.authenticate("token-value", get)
  end

  test "fetch_build_types: multiple buildTypes" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]

    builds = [
      %{
        "id" => "ProjectId_buildName1",
        "name" => "Build Name 1",
        "projectId" => "ProjectId1",
        "projectName" => "Project ID 1",
        "webUrl" => "https://example.com/link/to/build"
      },
      %{
        "id" => "ProjectId_buildName2",
        "name" => "Build Name 2",
        "projectId" => "ProjectId2",
        "projectName" => "Project ID 2",
        "webUrl" => "https://example.com/link/to/build"
      }
    ]

    body = %{"buildType" => builds}

    get = dummy_get(200, headers, body, options)

    assert {:ok, ^builds} = Source.fetch_build_types(get)
  end

  test "fetch_build_types: single buildTypes" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]

    build = %{
      "id" => "ProjectId_buildName1",
      "name" => "Build Name 1",
      "projectId" => "ProjectId1",
      "projectName" => "Project ID 1",
      "webUrl" => "https://example.com/link/to/build"
    }

    body = %{"buildType" => build}

    get = dummy_get(200, headers, body, options)

    assert {:ok, [^build]} = Source.fetch_build_types(get)
  end

  test "fetch_build_types: connection failure" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]
    body = %{}

    get = dummy_get(401, headers, body, options)

    assert {:error, :server_not_happy} = Source.fetch_build_types(get)
  end

  test "fetch_build: multiple buildTypes" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]

    builds = [
      %{
        "branchName" => "myBranch",
        "buildTypeId" => "build_type_id",
        "defaultBranch" => true,
        "href" => "/app/rest/buildQueue/id:120429306",
        "id" => 33,
        "state" => "queued",
        "webUrl" => "some url 1"
      },
      %{
        "branchName" => "otherBranch",
        "buildTypeId" => "build_type_id",
        "defaultBranch" => true,
        "href" => "/app/rest/buildQueue/id:120429307",
        "id" => 34,
        "state" => "queued",
        "webUrl" => "some url 2"
      }
    ]

    body = %{"build" => builds}

    get = dummy_get(200, headers, body, options)

    assert {:ok, ^builds} = Source.fetch_builds(100, get)
  end

  test "fetch_build: single buildTypes" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]

    build = %{
      "branchName" => "myBranch",
      "buildTypeId" => "build_type_id",
      "defaultBranch" => true,
      "href" => "/app/rest/buildQueue/id:120429306",
      "id" => 33,
      "state" => "queued",
      "webUrl" => "some url 1"
    }

    body = %{"build" => build}

    get = dummy_get(200, headers, body, options)

    assert {:ok, [^build]} = Source.fetch_builds(100, get)
  end

  test "fetch_build: connection failure" do
    headers = [{"Accept", "application/json"}]
    options = [hackney: [basic_auth: {"username-val", "password-val"}]]
    body = %{}

    get = dummy_get(401, headers, body, options)

    assert {:error, :server_not_happy} = Source.fetch_builds(100, get)
  end

  defp dummy_get(code, headers, body, options \\ []) do
    fn _, h, o ->
      assert [] == headers -- h
      assert [] == options -- o

      %{
        status_code: code,
        body: Poison.encode!(body)
      }
    end
  end
end
