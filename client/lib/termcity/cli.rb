require "termcity/api"
require "termcity/version"
require "termcity/formatters/simple"
require "termcity/formatters/iterm2"
require "termcity/summary"

module Termcity
  class CLI
    def self.simple_format(**args)
      new(**args).simple_format
    end

    def initialize(branch:, token:, host:, project_id:, revision:)
      @branch = branch
      @token = token
      @host = host
      @project_id = project_id
      @revision = revision
    end

    def simple_format
      api = Termcity::Api.new(
        token: @token,
        host: @host,
      )

      summary = Termcity::Summary.new(
        api: api,
        branch: @branch,
        revision: @revision,
        project_id: @project_id,
      )

      formatter =
        if using_iterm?
          Termcity::Formatters::Iterm2
        else
          Termcity::Formatters::Simple
        end

      formatter.new($stdout).format(summary)
    end

    def using_iterm?
      ENV["TERM_PROGRAM"] == "iTerm.app" &&
        ENV.fetch("TERM_PROGRAM_VERSION", "").match(/3.[23456789].[123456789]/)
    end
  end
end
