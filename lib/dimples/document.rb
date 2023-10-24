# frozen_string_literal: true

require_relative 'frontmatter'

module Dimples
  class Document
    attr_accessor :metadata, :contents, :path, :rendered_contents

    def initialize(path = nil, metadata = {})
      @path = path

      if @path
        @metadata, @contents = Dimples::FrontMatter.parse(File.read(path))
      else
        @metadata = {}
        @contents = ''
      end

      @metadata.merge!(metadata)
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

    def render(context = {}, content = '')
      context_obj = Object.new
      context.each do |key, value|
        context_obj.instance_variable_set("@#{key}", value)
      end

      @rendered_contents = renderer.render(context_obj) { content }
    end

    private

    def renderer
      @renderer ||= begin
        callback = proc { contents }

        if @path
          Tilt.new(@path, {}, &callback)
        else
          Tilt::StringTemplate.new(&callback)
        end
      end
    end

    def method_missing(method_name, *_args)
      @metadata[method_name] if @metadata.key?(method_name)
    end

    def respond_to_missing?(method_name, include_private)
      @metadata.key?(method_name) || super
    end
  end
end
