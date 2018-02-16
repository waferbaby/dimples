# frozen_string_literal: true

module Dimples
  class Category
    attr_accessor :name
    attr_accessor :slug
    attr_accessor :posts

    def initialize(site, slug)
      @site = site
      @slug = slug
      @name = @site.config.category_names[slug.to_sym] || slug.capitalize

      @posts = []
    end

    def inspect
      "#<#{self.class} @slug=#{slug} @name=#{name}>"
    end
  end
end
