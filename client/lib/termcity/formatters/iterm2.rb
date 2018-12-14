require "termcity/formatters/simple"

module Termcity
  module Formatters
    class Iterm2

      attr_reader :io, :simple_formatter
      def initialize(io)
        @io = io
        @simple_formatter = Simple.new(io)
      end

      def format(summary)
        rows = summary.builds.map do |build|
          cols = []

          text = simple_formatter.status_string(build) { |t|
            "#{linkify(t, build.fetch("web_url"))}#{" "*(10-t.length)}"
          }

          cols << linkify(text, build.fetch("web_url"))
          cols << build.fetch("build_type")
          cols.join(" ")
        end

        @io.puts(simple_formatter.summarize(summary, rows))
      end

      def linkify(text, url)
        "\e]8;;#{url}\a#{text}\e]8;;\a"
      end
    end
  end
end
