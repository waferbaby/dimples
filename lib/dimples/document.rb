require 'yaml'

module Dimples
  class Document
    FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m.freeze

    attr_accessor :metadata, :contents, :path

    def initialize(path)
      @path = path
      @contents = File.read(path)

      if matches = contents.match(FRONT_MATTER_PATTERN)
        @metadata = YAML.load(matches[1], symbolize_names: true)
        @contents = matches.post_match.strip
      else
        @metadata = {}
      end
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

      renderer.render(context_obj) { content }
    end

    private

    def renderer
      @renderer ||= begin
                      callback = proc { contents }
                      Tilt.new(@path, {}, &callback)
                    end
    end

    def method_missing(method_name, *args, &block)
      if @metadata.key?(method_name)
        @metadata[method_name]
      else
        nil
      end
    end
  end
end
