module Dimples
  class Category
    include Frontable

    attr_accessor :slug
    attr_accessor :name
    attr_accessor :posts

    def initialize(slug, name = nil)
      @slug = slug
      @name = name || @slug.capitalize

      @posts = []
    end
  end
end