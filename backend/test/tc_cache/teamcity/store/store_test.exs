defmodule TcCache.Teamcity.StoreTest do
  use TcCache.DataCase
  require IEx

  alias TcCache.Store

  describe "usage" do
    alias TcCache.Teamcity.Fixtures
    alias TcCache.Teamcity.Store.Build
    alias TcCache.Teamcity.Store.BuildType
    alias TcCache.Teamcity.Store

    test "find branch builds limits one (latest) result per build" do
      {3, _} =
        Store.upsert_build_types([
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_1",
            tc_name: "build_type_name_1",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_2",
            tc_name: "build_type_name_2",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_3",
            tc_name: "build_type_name_3",
            tc_project_id: "other_project_id",
            tc_project_name: "other_project_name"
          })
        ])

      {6, _} =
        Store.upsert_builds([
          Fixtures.Store.build_attrs(%{
            tc_id: 1,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_status: "FAILURE"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 2,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_status: "SUCCESS"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 3,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_2"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 4,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 5,
            tc_branch_name: "differentBranch",
            tc_build_type_id: "build_type_id_1"
          }),

          # shouldn't be picked up because different project
          Fixtures.Store.build_attrs(%{
            tc_id: 6,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_3"
          })
        ])

      expected = [
        %{
          build_type: "build_type_name_1",
          id: 4,
          project_name: "project_name",
          sha: "gitsha",
          status: "success",
          web_url: "some tc_web_url"
        },
        %{
          build_type: "build_type_name_2",
          id: 3,
          project_name: "project_name",
          sha: "gitsha",
          status: "success",
          web_url: "some tc_web_url"
        }
      ]

      assert expected == Store.build_info("project_id", "myBranch", nil)
    end

    test "build_infos defaults to detected latest build number" do
      {2, _} =
        Store.upsert_build_types([
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_1",
            tc_name: "build_type_name_1",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_2",
            tc_name: "build_type_name_2",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          })
        ])

      {4, _} =
        Store.upsert_builds([
          Fixtures.Store.build_attrs(%{
            tc_id: 1,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_number: "gitsha_newer"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 2,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_number: "gitsha_older"
          }),

          # the next build has different SHA order
          Fixtures.Store.build_attrs(%{
            tc_id: 3,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_2",
            tc_number: "gitsha_older"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 4,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_2",
            tc_number: "gitsha_newer"
          })
        ])

      expected = [
        %{
          build_type: "build_type_name_1",
          id: 1,
          project_name: "project_name",
          sha: "gitsha_newer",
          status: "success",
          web_url: "some tc_web_url"
        },
        %{
          build_type: "build_type_name_2",
          id: 4,
          project_name: "project_name",
          sha: "gitsha_newer",
          status: "success",
          web_url: "some tc_web_url"
        }
      ]

      assert expected == Store.build_info("project_id", "myBranch", nil)
    end

    test "calculates status correctly" do
      {6, _} =
        Store.upsert_build_types([
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_1",
            tc_name: "build_type_name_1",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_2",
            tc_name: "build_type_name_2",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_3",
            tc_name: "build_type_name_3",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_4",
            tc_name: "build_type_name_4",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_5",
            tc_name: "build_type_name_5",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_6",
            tc_name: "build_type_name_6",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          }),
        ])

      {6, _} =
        Store.upsert_builds([
          Fixtures.Store.build_attrs(%{
            tc_id: 1,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_state: "running",
            tc_status: "FAILURE"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 2,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_2",
            tc_state: "finished",
            tc_status: "FAILURE"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 3,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_3",
            tc_state: "running",
            tc_status: "SUCCESS"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 4,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_4",
            tc_state: "finished",
            tc_status: "SUCCESS"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 5,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_5",
            tc_state: "queued",
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 6,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_6",
            tc_state: "finished",
            tc_failed_to_start: true
          }),
        ])

        expected_statuses = [
          "failing",
          "failed",
          "running",
          "success",
          "queued",
          "not_run"
        ]

        actual_statuses =
          Store.build_info("project_id", "myBranch", nil)
          |> Enum.map(fn(b) -> b.status end)

        assert expected_statuses == actual_statuses
    end

    test "fetches ran/running builds AND queued builds (without a revision because they haven't started)" do
      {1, _} =
        Store.upsert_build_types([
          Fixtures.Store.build_type_attrs(%{
            tc_id: "build_type_id_1",
            tc_name: "build_type_name_1",
            tc_project_id: "project_id",
            tc_project_name: "project_name"
          })
        ])

      {3, _} =
        Store.upsert_builds([
          Fixtures.Store.build_attrs(%{
            tc_id: 1,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_number: "gitsha",
            tc_status: "FAILURE"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 2,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_number: "gitsha",
            tc_status: "SUCCESS"
          }),
          Fixtures.Store.build_attrs(%{
            tc_id: 3,
            tc_branch_name: "myBranch",
            tc_build_type_id: "build_type_id_1",
            tc_state: "queued",
            tc_status: nil,
            tc_number: nil
          })
        ])

      expected = [
        %{
          build_type: "build_type_name_1",
          id: 2,
          project_name: "project_name",
          sha: "gitsha",
          status: "success",
          web_url: "some tc_web_url"
        },
        %{
          build_type: "build_type_name_1",
          id: 3,
          project_name: "project_name",
          sha: nil,
          status: "queued",
          web_url: "some tc_web_url"
        }
      ]

      assert expected == Store.build_info("project_id", "myBranch", nil)
    end

    test "upsert_builds overrides" do
      {1, _} = Store.upsert_builds([Fixtures.Store.build_attrs(%{tc_id: 1})])
      time = ~N[1970-02-02 01:02:03.000000]

      {1, _} =
        Store.upsert_builds([Fixtures.Store.build_attrs(%{tc_id: 1, tc_state: "finished"})], time)

      assert [build] = Repo.all(Build)

      assert build.tc_id == 1
      assert build.tc_state == "finished"
      assert build.inserted_at == time
    end

    test "upsert_build_types overrides" do
      {1, _} = Store.upsert_build_types([Fixtures.Store.build_type_attrs("1")])

      new_attrs = Enum.into(%{tc_name: "new name"}, Fixtures.Store.build_type_attrs("1"))
      {2, _} = Store.upsert_build_types([new_attrs])

      assert [build_type] = Repo.all(BuildType)

      assert build_type.tc_id == "build_type_id_1"
      assert build_type.tc_name == "new name"
    end

    test "expire_builds" do
      old_time = ~N[1970-02-02 01:02:03.000000]
      cutoff_time = ~N[1980-02-02 01:02:03.000000]
      new_time = ~N[2001-02-02 01:02:03.000000]
      {1, _} = Store.upsert_builds([Fixtures.Store.build_attrs(%{tc_id: 1})], new_time)
      {1, _} = Store.upsert_builds([Fixtures.Store.build_attrs(%{tc_id: 2})], old_time)
      Store.expire_builds(cutoff_time)

      assert [build] = Repo.all(Build)

      assert build.tc_id == 1
    end
  end
end
