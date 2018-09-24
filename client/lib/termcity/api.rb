require "json"
require "net/http"
require "uri"

module Termcity
  class Api
    ALLOWED_BUILD_FILTERS = [
      :branch,
      :count,
      :defaultFilter,
      :failedtoStart,
      :project,
      :revision,
      :state,
    ]

    def initialize(token:, host:)
      @token = token
      @host = host
    end

    def summary(branch:, project_id:, revision:)
      path = "/builds?branch=#{branch}&project_id=#{project_id}"
      path = "#{path}&revision=#{revision}" if revision
      url = URI.join(@host, path).to_s
      get(url)
    end

    private

    def get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request["authorization"] = @token
      http.use_ssl = true
      response = http.request(request)
      raise "request failure:\n\n#{response.body}" unless response.code == "200"
      JSON.parse(response.body)
    end
  end
end
