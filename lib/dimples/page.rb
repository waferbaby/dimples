# frozen_string_literal: true

module Dimples
  class Page
    include Frontable

    attr_accessor :contents
    attr_accessor :metadata
    attr_accessor :path
    attr_writer :output_directory

    def initialize(site, path = nil)
      @site = site
      @path = path

      if @path
        @contents, @metadata = read_with_front_matter(@path)
      else
        @contents = ''
        @metadata = {}
      end
    end

    def write(context: {})
      FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)
      File.write(output_path, render(context))
    rescue SystemCallError => e
      raise PublishingError, "Failed to publish file at #{output_path} (#{e})"
    end

    def inspect
      "#<#{self.class} @slug=#{slug} @output_directory=#{output_directory}>"
    end

    private

    def output_directory
      @output_directory ||= if @path
                              File.dirname(@path).sub(
                                @site.paths[:pages],
                                @site.paths[:output]
                              )
                            else
                              @site.paths[:output]
                            end
    end

    def output_path
      @output_path ||= File.join(output_directory, "#{filename}.#{extension}")
    end

    def filename
      @metadata[:filename] || 'index'
    end

    def extension
      @metadata[:extension] || 'html'
    end

    def template
      @template ||= @site.templates[@metadata[:layout]]
    end

    def render(context = {})
      return @contents unless template
      template.render(page: self, context: context)
    end

    def method_missing(name, *args, &block)
      @metadata.key?(name) ? @metadata[name] : super
    end
  end
end
