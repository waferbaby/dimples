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

    def initialize(site, path = nil)
      @site = site
      @extension = 'html'
      @path = path

      if @path
        @filename = File.basename(@path, File.extname(@path))
        read_with_front_matter
      else
        @filename = 'index'
        @contents = ''
      end
    end

    def output_path(parent_path)
      parts = [parent_path]

      unless @path.nil?
        parts << File.dirname(@path).gsub(@site.source_paths[:pages], '')
      end

      parts << "#{@filename}.#{@extension}"

      File.join(parts)
    end

    def write(path, context = {})
      output = context ? render(context) : contents
      parent_path = File.dirname(path)

      FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

      File.open(path, 'w+') do |file|
        file.write(output)
      end
    rescue SystemCallError => e
      error_message = "Failed to write #{path} (#{e.message})"
      raise Errors::PublishingError, error_message
    end
  end
end
