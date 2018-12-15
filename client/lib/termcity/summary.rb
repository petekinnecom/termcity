module Termcity
  class Summary
    def initialize(revision:, api:, branch:, project_id:, reponame:)
      @branch = branch
      @project_id = project_id
      @api = api
      @revision = revision
      @reponame = reponame
    end

    def builds
      data[:builds]
    end

    def counts
      data[:counts]
    end

    def teamcity_link
      data.dig(:links, :teamcity_overview)
    end

    def circle_link
      data.dig(:links, :circle_overview)
    end

    def data
      # this is messy but allows for a single pass
      @data ||= begin
        counts = {
          total: 0,
          success: 0,
          failure: 0,
          running: 0,
          queued: 0,
          failstrt: 0,
          re_enqueued: 0,
        }

        summary = @api.summary(
          branch: @branch,
          project_id: @project_id,
          revision: @revision,
          reponame: @reponame
        )

        builds = summary.fetch("builds")
          .sort_by {|b| b.fetch("build_type")}
          .map {|b| summarize(b, counts) }

        {
          links: {
            teamcity_overview: summary.dig("links", "teamcity_overview"),
            circle_overview: summary.dig("links", "circle_overview")
          },
          builds: builds,
          counts: counts
        }
      end
    end

    def summarize(build, counts)
      count_type =
        if ["failing", "failed"].include?(build.fetch("status"))
          :failure
        else
          build.fetch("status").to_sym
        end
      counts[count_type] += 1
      counts[:total] += 1
      counts[:re_enqueued] +=1 if build.fetch("re_enqueued")
      build
    end
  end
end

