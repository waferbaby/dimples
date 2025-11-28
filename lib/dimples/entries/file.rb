# frozen_string_literal: true

module Dimples
  module Entries
    # A class representing a single entry based on a file (with optional frontmatter metadata) that can be rendered.
    class File < Base
      attr_accessor :path

      def initialize(site:, path:)
        @path = ::File.expand_path(path)
        super(site: site, contents: ::File.read(@path))
      end

      def write(metadata: {})
        super(output_path: ::File.join(output_directory, filename), metadata: metadata)
      end

      def output_directory
        @output_directory ||= @site.config.build_paths[:root]
      end

      def url
        @path.gsub(@site.config.build_paths[:root], '').concat('/')
      end
    end
  end
end
