# frozen_string_literal: true

module Dimples
  # A single page on a site.
  class Page < Entry
    def initialize(site:, path:)
      super(site: site, source: Pathname.new(path))
    end

    def output_directory
      @output_directory ||= File.dirname(@path).gsub(
        @site.config.source_paths[:pages],
        @site.config.build_paths[:root]
      ).concat('/')
    end

    private

    def default_metadata
      super.merge!(layout: 'page')
    end
  end
end
