# frozen_string_literal: true

module Dimples
  module Sources
    # A single page on a site.
    class Page < Base
      def output_directory
        @output_directory ||= File.dirname(@path).gsub(
          @site.config.source_paths[:pages],
          @site.config.build_paths[:root]
        ).concat('/')
      end

      def url
        output_directory.tap { |url| url.concat(filename) unless filename == 'index.html' }
      end

      def template
        @template ||= Tilt::ERBTemplate.new { @contents }
      end

      private

      def default_metadata
        super.merge!(layout: 'page')
      end
    end
  end
end
