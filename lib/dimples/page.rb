# frozen_string_literal: true

module Dimples
  # A class that models a single site page.
  class Page
    include Frontable
    include Renderable

    attr_accessor :path
    attr_accessor :title
    attr_accessor :filename
    attr_accessor :extension
    attr_accessor :layout
    attr_accessor :contents
    attr_accessor :output_directory

    def initialize(site, path = nil)
      @site = site
      @extension = 'html'
      @path = path

      if @path
        @filename = File.basename(@path, File.extname(@path))
        @output_directory = File.dirname(@path).gsub(
          @site.source_paths[:pages],
          @site.output_paths[:site]
        )

        read_with_front_matter
      else
        @filename = 'index'
        @contents = ''
        @output_directory = @site.output_paths[:site]
      end
    end

    def output_path
      File.join(@output_directory, "#{@filename}.#{@extension}")
    end

    def write(context = {})
      FileUtils.mkdir_p(@output_directory) unless Dir.exist?(@output_directory)

      File.open(output_path, 'w+') do |file|
        file.write(context ? render(context) : contents)
      end
    rescue SystemCallError => e
      error_message = "Failed to write #{path} (#{e.message})"
      raise Errors::PublishingError, error_message
    end

    def inspect
      "#<Dimples::Page @output_path=#{output_path}>"
    end
  end
end
