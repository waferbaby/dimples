# frozen_string_literal: true

module Dimples
  # A single template used when rendering pages, posts and other templates.
  class Template
    attr_accessor :path
    attr_accessor :contents
    attr_accessor :metadata

    def initialize(site, path)
      @site = site
      @path = path

      data = File.read(path)
      @contents, @metadata = FrontMatter.parse(data)
    end

    def render(context = {}, body = nil)
      context[:template] ||= Hashie::Mash.new(@metadata)
      renderer.render(context, body)
    end

    private

    def renderer
      @renderer ||= Renderer.new(@site, self)
    end
  end
end
