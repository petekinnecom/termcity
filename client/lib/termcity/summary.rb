module Termcity
  class Summary
    def initialize(revision: nil, api:, branch: nil, project_id:)
      @branch = branch
      @project_id = project_id
      @api = api
    end

    def builds
      @api.builds(branch: @branch, project_id: @project_id)
        .sort_by {|b| b.fetch("build_type")}
    end
  end
end

