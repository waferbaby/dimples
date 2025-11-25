# frozen_string_literal: true

module Dimples
  module Sources
    # A base class representing a source file (with optional frontmatter metadata) that can be rendered to a file.
    class Base
      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :path, :metadata, :contents, :rendered_contents

      def initialize(site:, path:)
        @site = site
        @path = File.expand_path(path)
        @contents = File.read(@path)

        @metadata = default_metadata
        parse_metadata(@contents)
      end

      def parse_metadata(contents)
        matches = contents.match(FRONT_MATTER_PATTERN)
        return unless matches

        @metadata.merge!(YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date]))
        @contents = matches.post_match.strip
      end

      def write(metadata: {})
        output_path       = File.join(output_directory, filename)
        parent_directory  = File.dirname(output_path)

        output = render(context: metadata)

        FileUtils.mkdir_p(parent_directory) unless File.directory?(parent_directory)
        File.write(output_path, output)
      end

      def render(context: {}, body: nil)
        context[:site] ||= @site.metadata
        context[:page] ||= metadata

        @rendered_contents = template.render(Metadata.new(context)) { body }
        return @rendered_contents unless @metadata[:layout] && @site.layouts[@metadata[:layout]]

        @site.layouts[@metadata[:layout]].render(context:, body: @rendered_contents)
      end

      def output_directory
        @output_directory ||= @site.config.build_paths[:root]
      end

      def url
        @path.gsub(@site.config.build_paths[:root], '').concat('/')
      end

      def template
        raise NotImplementedError, 'You must set a Tilt template for this class.'
      end

      private

      def default_metadata
        {
          layout: nil,
          filename: 'index.html',
        }
      end

      def method_missing(method_name, *args, &block)
        return @metadata[method_name] if @metadata.key?(method_name)

        nil
      end

      def respond_to_missing?(method_name, include_private = false)
        @metadata.key?(method_name) || super
      end
    end
  end
end
