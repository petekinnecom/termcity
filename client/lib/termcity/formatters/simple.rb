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

      COLORS = {
        failing: :red,
        queued: :yellow,
        running: :blue,
        failed_to_start: :default,
        failed: :red,
        success: :green
      }

      attr_reader :io
      def initialize(io)
        @io = io
      end

      def format(summary)
        rows = summary.builds.map do |raw:, status:|
          cols = []
          cols << status_string(status)
          cols << raw.fetch("build_type")
          cols << raw.fetch("web_url")

          cols.join(" : ")
        end

        @io.puts(summarize(summary, rows))
      end

      def status_string(type:, re_enqueued:)
        name = STATUSES.fetch(type)
        name = "#{name},q" if re_enqueued
        color = COLORS[type]

        colorize(name.ljust(10), color)
      end

      def summarize(summary, rows)
        if summary.builds.empty?
          "No builds found"
        elsif summary.counts[:queued] == summary.counts[:total]
          "This revision may still be in the queue (or may be unkown/old)"
        else
          [
            rows,
            "",
            "Revision: #{summary.builds.first.dig(:raw, "sha")}",
            "Overview: #{summary.overview_link}",
            counts(summary),
          ].join("\n")
        end
      end

      def counts(summary)
        [
          ["Total", summary.counts[:total]],
          ["Success", summary.counts[:success]],
          ["failure", summary.counts[:failure]],
          ["Running", summary.counts[:running]],
          ["Queued", summary.counts[:queued]],
          ["Re-Queued", summary.counts[:re_enqueued]]
        ]
          .map {|name, count| "#{name}: #{count}"}
          .join(", ")
      end
    end
  end
end
