# frozen_string_literal: true

module Dimples
  module Entries
    # A page from a site with a date.
    class Post < Base
      def initialize(site:, path:)
        super(site: site, source: Pathname.new(path))
      end

      def output_directory
        @output_directory ||= File.dirname(@path).gsub(
          @site.config.source_paths[:posts],
          @site.config.build_paths[:posts]
        ).concat("/#{slug}/")
      end

      def slug
        File.basename(@path, '.markdown')
      end

      def template
        @template ||= Tilt::RedcarpetTemplate.new { @contents }
      end

      private

      def default_metadata
        super.tap do |defaults|
          defaults[:layout] = 'post'
          defaults[:slug] = slug
          defaults[:date] = File.birthtime(@path)
          defaults[:categories] = []
        end
      end
    end
  end
end
