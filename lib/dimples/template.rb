# frozen_string_literal: true

module Dimples
  class Template
    include Frontable

    attr_accessor :path
    attr_accessor :contents
    attr_accessor :metadata

    def initialize(site, path)
      @site = site
      @path = path
      @contents, @metadata = read_with_front_matter(path)
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
