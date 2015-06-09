module Dimples
  class Category
    include Frontable

    attr_accessor :slug
    attr_accessor :name
    attr_accessor :posts

    def initialize(slug, path = nil)
      @slug = slug
      @name = @slug.capitalize

      read_with_yaml(path) if path

      @posts = []
    end
  end
end