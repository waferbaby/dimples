# frozen_string_literal: true

module Dimples
  class Template
    include Frontable
    include Renderable

    attr_accessor :path
    attr_accessor :contents
    attr_accessor :metadata

    def initialize(site, path)
      @site = site
      @path = path
      @contents, @metadata = read_with_front_matter(path)
    end
  end
end
