module Dimples
  module Sources
    # A base class representing a source file with frontmatter metadata that can be rendered.
    class Base
      FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

      attr_accessor :path, :metadata, :contents

      def initialize(site, path)
        @site = site
        @path = File.expand_path(path)

        @metadata = default_metadata
        @contents = File.read(@path)

        matches = @contents.match(FRONT_MATTER_PATTERN)
        return unless matches

        @metadata.merge!(YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date]))
        @contents = matches.post_match.strip
      end

      def write(output_path = nil, metadata = {})
        metadata[:site] ||= @site
        metadata[context_key] ||= self

        output = render(metadata)

        output_path = File.join(output_directory, filename) if output_path.nil?
        output_dir = File.dirname(output_path)

        FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
        File.write(output_path, output)
      end

      def render(metadata = {}, body = nil)
        output = template.render(context(metadata)) { body }
        return output unless @metadata[:layout] && @site.layouts[@metadata[:layout]]

        @site.layouts[@metadata[:layout]].render(metadata, output)
      end

      def context(metadata)
        Object.new.tap do |context|
          metadata.each { |key, variable| context.instance_variable_set("@#{key}", variable) }
        end
      end

      def default_metadata
        {
          layout: nil,
          filename: 'index.html'
        }
      end

      def output_directory
        @site.config[:output][:root]
      end

      def url
        @metadata[:url] || output_directory.gsub(@site.config[:output][:root], '')
      end

      def template
        raise NotImplementedError, 'You must set a Tilt template for this class.'
      end

      private

      def context_key
        :page
      end

      def method_missing(method_name, *_args)
        @metadata[method_name] if @metadata.key?(method_name)
      end

      def respond_to_missing?(method_name, include_private)
        @metadata.key?(method_name) || super
      end
    end
  end
end
