# frozen_string_literal: true

module Dimples
  # A class for a single layout used on a site.
  class Layout
    include Metadata

    def initialize(path, config)
      @config = config
      parse_file(path)
    end

    def layout
      @metadata[:layout]
    end

    def template
      @template ||= Tilt::ERBTemplate.new { @contents }
    end
  end
end
