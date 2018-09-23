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
        rows = summary.builds.map do |raw:, status:|
          cols = []
          cols << simple_formatter.status_string(status)
          cols << linkify(raw.fetch("web_url"))
          cols << raw.fetch("build_type")
          cols.join(" ")
        end

        @io.puts(
          [
            simple_formatter.header(summary),
            rows
          ].join("\n")
        )
      end

      def linkify(url)
        "\e]8;;#{url}\aLink\e]8;;\a"
      end
    end
  end
end
