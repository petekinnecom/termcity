require "termcity/formatters/util/color"

module Termcity
  module Formatters
    class Simple
      include Utils::Color

      STATUSES = {
        queued: "queued",
        failing: "failing",
        running: "running",
        failed_to_start: "failstrt",
        failed: "failed",
        success: "success"
      }

      attr_reader :io
      def initialize(io)
        @io = io
      end

      def format(summary)
        summary.builds.each do |build|
          cols = []

          cols << status(build)
          cols << build.fetch("build_type")
          cols << build.fetch("web_url")

          io.puts(cols.join(" : "))
        end
      end

      def status(build)
        re_enqueued = build.fetch("re_enqueued")

        if build.fetch("state") == "queued"
          yellow(status_name(:queued))
        elsif build.fetch("state") == "running"
          if build.fetch("status") == "FAILURE"
            red(status_name(:failing, re_enqueued: re_enqueued))
          else
            blue(status_name(:running, re_enqueued: re_enqueued))
          end
        else
          if build.fetch("failedToStart", false)
            status_name(:failed_to_start, re_enqueued: re_enqueued)
          elsif build.fetch("status") == "FAILURE"
            red(status_name(:failed, re_enqueued: re_enqueued))
          else
            green(status_name(:success, re_enqueued: re_enqueued))
          end
        end
      end

      def status_name(type, re_enqueued: false)
        if re_enqueued
          "#{STATUSES.fetch(type)},q".ljust(10)
        else
          STATUSES.fetch(type).ljust(10)
        end
      end
    end
  end
end
