# frozen_string_literal: true

module Dimples
  module Sources
    # A single page on a site.
    class Page < Base
      def output_directory
        @output_directory ||= File.dirname(@path).gsub(
          @site.config[:sources][:pages],
          @site.config[:output][:root]
        ).concat('/')
      end

      def url
        super.tap do |url|
          url.concat(filename) unless filename == 'index.html'
        end
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
