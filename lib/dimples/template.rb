# frozen_string_literal: true

module Dimples
  # A class that models a single template.
  class Template
    include Frontable
    include Renderable

    attr_accessor :slug
    attr_accessor :title
    attr_accessor :path
    attr_accessor :contents
    attr_accessor :rendered_contents

    def initialize(site, path)
      @site = site
      @slug = File.basename(path, File.extname(path))
      @path = path

      @contents = read_with_front_matter(path)
    end
  end
end
