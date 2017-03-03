module Dimples
  class Category
    attr_accessor :name
    attr_accessor :slug
    attr_accessor :posts

    def initialize(name, slug)
     @name = name
     @slug = slug
     @posts = []
    end
  end
end
