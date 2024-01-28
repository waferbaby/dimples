# frozen_string_literal: true

module Dimples
  # A page from a site with a date.
  class Post
    include Metadata

    def initialize(path, config)
      @config = config
      parse_file(path)
    end

    def date
      @metadata.fetch(:date, File.birthtime(@path))
    end

    def layout
      @metadata.fetch(:layout, 'post')
    end

    def categories
      @metadata.fetch(:categories, [])
    end

    def slug
      @metadata.fetch(:slug, File.basename(@path, '.markdown'))
    end

    def output_directory
      @output_directory ||= File.dirname(@path).gsub(@config[:sources][:posts], @config[:output][:posts]) << "/#{slug}/"
    end

    def url
      @url ||= output_directory.gsub(@config[:output][:root], '')
    end

    def template
      @template ||= Tilt::RedcarpetTemplate.new { @contents }
    end
  end
end
