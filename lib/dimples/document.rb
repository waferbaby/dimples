require 'yaml'

module Dimples
  class Document
    FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m.freeze

    attr_accessor :metadata, :contents

    def initialize(path)
      @path = path
      @contents = File.read(path)

      if matches = contents.match(FRONT_MATTER_PATTERN)
        @metadata = YAML.load(matches[1])
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
      @metadata.fetch('layout', nil)
    end

    def render(content = '', context = {})
      renderer.render(Object.new, context) { content }
    end

    def renderer
      @renderer ||= begin
                      callback = proc { contents }
                      Tilt.new(@path, {}, &callback)
                    end
    end
  end
end
