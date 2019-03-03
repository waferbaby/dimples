# frozen_string_literal: true

module Dimples
  # A single page on a site.
  class Page
    attr_accessor :contents
    attr_accessor :metadata
    attr_accessor :path

    def initialize(site, path = nil)
      @site = site
      @path = path

      if @path
        data = File.read(@path)
        @contents, @metadata = FrontMatter.parse(data)
      else
        @contents = ''
        @metadata = {}
      end
    end

    def filename
      @metadata[:filename] || 'index'
    end

    def extension
      @metadata[:extension] || 'html'
    end

    def render(context = {})
      metadata = @metadata.dup
      metadata.merge!(context[:page]) if context[:page]

      context[:page] = Hashie::Mash.new(metadata)

      renderer.render(context)
    end

    def write(output_directory, context = {})
      FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)
      output_path = File.join(output_directory, "#{filename}.#{extension}")

      File.write(output_path, render(context))
    rescue SystemCallError => e
      raise PublishingError, "Failed to publish file at #{output_path} (#{e})"
    end

    private

    def renderer
      @renderer ||= Renderer.new(@site, self)
    end

    def method_missing(method_name, *args, &block)
      if @metadata.key?(method_name)
        @metadata[method_name]
      elsif (matches = method_name.match(/([a-z_]+)=/))
        @metadata[matches[1].to_sym] = args[0]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @metadata.key?(method_name) || method_name.match?(/([a-z_]+)=/) || super
    end
  end
end
