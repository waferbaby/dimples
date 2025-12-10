# frozen_string_literal: true

require 'forwardable'
require 'pathname'

module Dimples
  module Entries
    # A class representing a dynamic source entry
    class Base
      include Forwardable

      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :path, :contents, :rendered_contents
      attr_reader :metadata

      def initialize(site:, source:)
        @site = site

        contents = case source
                   when Pathname
                     @path = File.expand_path(source)
                     File.read(@path)
                   when String
                     source
                   end

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
      end

      def write(output_path: nil, context: {})
        output_path = File.join(output_directory, @metadata[:filename]) if output_path.nil?

        parent_directory = File.dirname(output_path)
        output = render(context: context)

        FileUtils.mkdir_p(parent_directory) unless File.directory?(parent_directory)
        File.write(output_path, output)
      end

      def render(context: {}, body: nil)
        context[:site] ||= @site.metadata
        context[:page] ||= @metadata

        @rendered_contents = template.render(Metadata.new(context)) { body }

        layout = @site.layouts[@metadata.layout.to_sym] if @metadata.layout
        return @rendered_contents if layout.nil?

        layout.render(context: context, body: @rendered_contents)
      end

      def output_directory
        @output_directory ||= @site.config.build_paths[:root]
      end

      def template
        @template ||= Tilt::ERBTemplate.new { @contents }
      end

      def method_missing(method_name, *_args)
        @metadata.send(method_name)
      end

      def respond_to_missing?(method_name, include_private = false)
        true
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
