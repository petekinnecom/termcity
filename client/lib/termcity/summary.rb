module Termcity
  class Summary
    def initialize(revision:, api:, branch:, project_id:)
      @branch = branch
      @project_id = project_id
      @api = api
      @revision = revision
    end

    def builds
      data[:builds]
    end

    def counts
      data[:counts]
    end

    def overview_link
      data.dig(:links, :overview)
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

        summary = @api.summary(branch: @branch, project_id: @project_id, revision: @revision)

        builds = summary.fetch("builds")
          .sort_by {|b| b.fetch("build_type")}
          .map {|b| summarize(b, counts) }

        {
          links: {overview: summary.dig("links", "overview")},
          builds: builds,
          counts: counts
        }
      end
    end

    def summarize(build, counts)
      status = status(build)

      count_type =
        if ["failing", "failed"].include?(build.fetch("status"))
          :failure
        else
          build.fetch("status").to_sym
        end
      counts[count_type] += 1
      counts[:total] += 1
      counts[:re_enqueued] +=1 if build.fetch("re_enqueued")
    end
  end
end

