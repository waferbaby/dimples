# frozen_string_literal: true

module Dimples
  # A class that models a single template.
  class Template
    include Frontable

    attr_accessor :path
    attr_accessor :title
    attr_accessor :slug
    attr_accessor :layout
    attr_accessor :contents
    attr_accessor :rendered_contents

    def initialize(site, path)
      @site = site
      @slug = File.basename(path, File.extname(path))
      @path = path

      @contents = read_with_front_matter(path)
    end

    def render(context = {}, body = nil)
      renderer.render(context, body)
    end

    def renderer
      @renderer ||= Renderer.new(@site, self)
    end
  end
end
