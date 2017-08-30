# frozen_string_literal: true

module Dimples
  # A class that models a single interview category.
  class Category
    attr_accessor :name
    attr_accessor :slug
    attr_accessor :posts

    def initialize(site, slug)
      @site = site
      @slug = slug
      @name = @site.config['category_names'][slug] || slug.capitalize
      @posts = []
    end

    def inspect
      "#<Dimples::Category @slug=#{@slug} @name=#{@name}>"
    end
  end
end
