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

    def data
      # this is messy but allows for a single pass
      @data ||= begin
        counts = {
          total: 0,
          success: 0,
          failure: 0,
          running: 0,
          queued: 0,
          re_enqueued: 0,
        }

        builds = @api.builds(branch: @branch, project_id: @project_id, revision: @revision)
          .sort_by {|b| b.fetch("build_type")}
          .map {|b| summarize(b, counts) }

        {
          builds: builds,
          counts: counts
        }
      end
    end

    def summarize(build, counts)
      status = status(build)

      count_type =
        if [:failing, :failed].include?(status[:type])
          :failure
        else
          status[:type]
        end
      counts[count_type] += 1
      counts[:total] += 1
      counts[:re_enqueued] +=1 if status[:re_enqueued]

      {
        raw: build,
        status: status
      }
    end

    def status(build)
      re_enqueued = build.fetch("re_enqueued")

      if build.fetch("state") == "queued"
        {type: :queued, re_enqueued: false}
      elsif build.fetch("state") == "running"
        if build.fetch("status") == "FAILURE"
          {type: :failing, re_enqueued: re_enqueued}
        else
          {type: :running, re_enqueued: re_enqueued}
        end
      else
        if build.fetch("failedToStart", false)
          {type: :failed_to_start, re_enqueued: re_enqueued}
        elsif build.fetch("status") == "FAILURE"
          {type: :failed, re_enqueued: re_enqueued}
        else
          {type: :success, re_enqueued: re_enqueued}
        end
      end
    end
  end
end

