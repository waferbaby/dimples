# frozen_string_literal: true

module Dimples
  # A single post category for a site.
  class Category
    attr_reader :name
    attr_reader :slug
    attr_accessor :posts

    def initialize(site, slug)
      @site = site
      @slug = slug
      @name = @site.config.category_names[slug.to_sym] || slug.capitalize

      @posts = []
    end
  end
end
