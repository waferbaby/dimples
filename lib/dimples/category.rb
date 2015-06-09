module Dimples
  class Category
    include Frontable

    attr_accessor :slug
    attr_accessor :path
    attr_accessor :name
    attr_accessor :posts

    def initialize(slug, path)
      @slug = slug
      @path = path
      @name = @slug.capitalize

      read_with_yaml(path)

      @posts = []
    end
  end
end