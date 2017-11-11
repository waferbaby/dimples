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
        @output_directory = File.dirname(@path).sub(
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
      File.join(@output_directory, output_filename)
    end

    def output_filename
      "#{@filename}.#{@extension}"
    end

    def url
      absolute_output_directory = File.absolute_path(@output_directory)

      absolute_output_directory.sub(@site.output_paths[:site], '').tap do |url|
        url[0] = '/' unless url[0] == '/'
        url.concat('/') unless url[-1] == '/'
        url.concat(output_filename) if filename != 'index'
      end
    end

    def write(context = {})
      FileUtils.mkdir_p(@output_directory) unless Dir.exist?(@output_directory)

      File.open(output_path, 'w+') do |file|
        file.write(render(context))
      end
    rescue SystemCallError => e
      error_message = "Failed to write #{path} (#{e.message})"
      raise Errors::PublishingError, error_message
    end

    def inspect
      "#<#{self.class} @output_path=#{output_path}>"
    end
  end
end
