# frozen_string_literal: true

module Dimples
  module Sources
    # A page from a site with a date.
    class Post < Base
      def output_directory
        @output_directory ||= File.dirname(@path).gsub(
          @site.config[:sources][:posts],
          @site.config[:output][:posts]
        ).concat("/#{@metadata[:slug]}/")
      end

      def template
        @template ||= Tilt::RedcarpetTemplate.new { @contents }
      end

      private

      def default_metadata
        super.tap do |defaults|
          defaults[:layout] = 'post'
          defaults[:slug] = File.basename(@path, '.markdown')
          defaults[:date] = File.birthtime(@path)
          defaults[:categories] = []
        end
      end
    end
  end
end
