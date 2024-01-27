# frozen_string_literal: true

module Dimples
  # A single page on a site.
  class Page
    attr_accessor :metadata, :contents, :path, :rendered_contents

    def initialize(path, config)
      @path = File.expand_path(path)
      @config = config
      @metadata, @contents = Dimples::FrontMatter.parse(File.read(@path))
    end

    def filename
      "#{basename}.#{extension}"
    end

    def basename
      @metadata.fetch(:filename, 'index')
    end

    def extension
      @metadata.fetch(:extension, 'html')
    end

    def layout
      @metadata.fetch(:layout, nil)
    end

    def slug
      @metadata.fetch(:slug, File.basename(@path, File.extname(@path)))
    end

    def template
      @template ||= template_class.new(nil, 1, template_options) { @contents }
    end

    def output_directory
      @output_directory ||= File.dirname(@path).gsub(@config[:sources][:pages], '') << '/'
    end

    def url
      @url ||= String.new.tap do |url|
        url << output_directory unless output_directory == '/'
        url << ('/' + filename) unless basename == 'index'
      end
    end

    private

    def template_class
      Tilt::ErbTemplate
    end

    def template_options
      {}
    end
  end
end
