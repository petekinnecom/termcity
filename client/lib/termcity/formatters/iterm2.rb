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
        summary.builds.each do |build|
          cols = []
          cols << simple_formatter.status(build)
          cols << linkify(build.fetch("web_url"))
          cols << build.fetch("build_type")
          io.puts(cols.join(" "))
        end
      end

      def linkify(url)
        "\e]8;;#{url}\aLink\e]8;;\a"
      end
    end
  end
end
