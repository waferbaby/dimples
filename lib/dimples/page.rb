# frozen_string_literal: true

module Dimples
  # A single page on a site.
  class Page
    include Metadata

    def initialize(path, config)
      @config = config
      parse_file(path)
    end

    def layout
      @metadata.fetch(:layout, 'default')
    end

    def output_directory
      @output_directory ||= File.dirname(@path).gsub(@config[:sources][:pages], @config[:output][:root]) << '/'
    end

    def url
      @url ||= String.new.tap do |url|
        url << output_directory unless output_directory == '/'
        url << "/#{filename}" unless basename == 'index'
      end
    end

    def template
      @template ||= Tilt::ERBTemplate.new { @contents }
    end
  end
end
