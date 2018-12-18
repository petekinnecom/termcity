require "termcity/formatters/util/color"

module Termcity
  module Formatters
    class Simple
      include Utils::Color

      COLORS = {
        "failing" => :red,
        "queued" => :yellow,
        "running" => :blue,
        "not_run" => :default,
        "failed" => :red,
        "success" => :green
      }

      attr_reader :io
      def initialize(io)
        @io = io
      end

      def format(summary)
        rows = summary.builds.map { |build|
          cols = []
          cols << status_string(build)
          cols << build.fetch("build_type")
          cols << build.fetch("web_url")

          cols.join(" : ")
        }

        @io.puts(summarize(summary, rows))
      end

      def status_string(build)
        name = build.fetch("status")
        name = "#{name},q" if build.fetch("re_enqueued")
        color = COLORS[build.fetch("status")] || :default

        text =
          if block_given?
            yield(name)
          else
            name.ljust(10)
          end
        colorize(text, color)
      end

      def summarize(summary, rows)
        if summary.builds.empty?
          "No builds found"
        elsif summary.counts[:queued] == summary.counts[:total]
          "This revision may still be in the queue (or may be unkown/old)"
        else

          revision = summary.builds.map {|b| b.dig("sha")}.compact.first
          [
            rows,
            "",
            "Revision: #{revision}",
            "Teamcity Overview: #{summary.teamcity_link}",
            "CircleCI Overview: #{summary.circle_link}",
            counts(summary),
          ].join("\n")
        end
      end

      def counts(summary)
        [
          ["Total", summary.counts[:total]],
          ["Success", summary.counts[:success]],
          ["Failure", summary.counts[:failure]],
          ["Running", summary.counts[:running]],
          ["Not Run", summary.counts[:not_run]],
          ["Queued", summary.counts[:queued]],
          ["Re-Queued", summary.counts[:re_enqueued]]
        ]
          .map {|name, count| "#{name}: #{count}"}
          .join(", ")
      end
    end
  end
end
