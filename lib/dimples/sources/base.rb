# frozen_string_literal: true

module Dimples
  module Sources
    # A base class representing a source file with frontmatter metadata that can be rendered.
    class Base
      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :path, :metadata, :contents

      def initialize(site:, path:)
        @site = site
        @path = File.expand_path(path)

        @metadata = default_metadata
        @contents = File.read(@path)

        parse_metadata(@contents)
        assign_metadata
      end

      def parse_metadata(contents)
        matches = contents.match(FRONT_MATTER_PATTERN)
        return unless matches

        @metadata.merge!(YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date]))
        @contents = matches.post_match.strip
      end

      def assign_metadata
        @metadata.each_key do |key|
          self.class.send(:define_method, key.to_sym) { @metadata[key] }
        end
      end

      def write(output_path: nil, metadata: {})
        output_path = File.join(output_directory, filename) if output_path.nil?
        output_dir = File.dirname(output_path)

        @metadata[:url] = url_for(output_dir)

        output = render(context: metadata)

        FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
        File.write(output_path, output)
      end

      def render(context: {}, body: nil)
        context[:site] ||= @site.metadata
        context[:page] ||= metadata

        output = template.render(Metadata.new(context)) { body }
        return output unless @metadata[:layout] && @site.layouts[@metadata[:layout]]

        @site.layouts[@metadata[:layout]].render(context:, body: output)
      end

      def output_directory
        @site.config.build_paths[:root]
      end

      def url_for(path)
        path.gsub(@site.config.build_paths[:root], '').concat('/')
      end

      def template
        raise NotImplementedError, 'You must set a Tilt template for this class.'
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
