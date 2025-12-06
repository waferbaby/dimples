# frozen_string_literal: true

require 'forwardable'

module Dimples
  module Entries
    # A class representing a dynamic source entry
    class Base
      include Forwardable

      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :contents, :rendered_contents
      attr_reader :metadata

      def initialize(site:, contents:)
        @site = site

        parse_metadata(contents)
      end

      def parse_metadata(contents)
        metadata = default_metadata

        matches = contents.match(FRONT_MATTER_PATTERN)
        if matches
          metadata.merge!(YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date]))
          @contents = matches.post_match.strip
        else
          @contents = contents
        end

        @metadata = Metadata.new(metadata)
        @metadata.each_key { |key| def_delegator :@metadata, key.to_sym }
      end

      def write(output_path:, metadata: {})
        parent_directory = ::File.dirname(output_path)
        output = render(context: metadata)

        FileUtils.mkdir_p(parent_directory) unless ::File.directory?(parent_directory)
        ::File.write(output_path, output)
      end

      def render(context: {}, body: nil)
        context[:site] ||= @site.metadata.to_h
        context[:page] ||= @metadata.to_h

        @rendered_contents = template.render(Metadata.new(context)) { body }

        layout = @site.layouts[@metadata[:layout].to_sym] if @metadata[:layout]
        return @rendered_contents if layout.nil?

        layout.render(context: context, body: @rendered_contents)
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
    end
  end
end
