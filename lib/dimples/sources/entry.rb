# frozen_string_literal: true

module Dimples
  module Sources
    # A class representing a dynamic source entry
    class Entry
      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :metadata, :contents, :rendered_contents

      def initialize(site:, contents:)
        @site = site

        parse_metadata(contents)
      end

      def parse_metadata(contents)
        @metadata = default_metadata

        matches = contents.match(FRONT_MATTER_PATTERN)
        unless matches
          @contents = contents
          return
        end

        @metadata.merge!(YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date]))
        @contents = matches.post_match.strip
      end

      def write(output_path:, metadata: {})
        parent_directory = File.dirname(output_path)
        output = render(context: metadata)

        FileUtils.mkdir_p(parent_directory) unless File.directory?(parent_directory)
        File.write(output_path, output)
      end

      def render(context: {}, body: nil)
        context[:site] ||= @site.metadata
        context[:page] ||= metadata

        @rendered_contents = template.render(Metadata.new(context)) { body }
        return @rendered_contents unless @metadata[:layout] && @site.layouts[@metadata[:layout]]

        @site.layouts[@metadata[:layout]].render(context: context, body: @rendered_contents)
      end

      def output_directory
        @output_directory ||= @site.config.build_paths[:root]
      end

      def template
        @template ||= Tilt::ERBTemplate.new { @contents }
      end

      private

      def default_metadata
        {
          layout: nil,
          filename: 'index.html'
        }
      end

      def method_missing(method_name, *_args)
        return @metadata[method_name] if @metadata.key?(method_name)

        nil
      end

      def respond_to_missing?(method_name, include_private = false)
        @metadata.key?(method_name) || super
      end
    end
  end
end
