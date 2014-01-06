module Salt
  class Post < Page
    attr_accessor :slug, :date, :contents, :categories

    def self.path
      "posts"
    end

    def initialize(path)
      super

      parts = File.basename(path, File.extname(path)).match(/(\d{4})-(\d{2})-(\d{2})-(.+)/)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @filename = 'index'
      @categories = []
    end

    def type
      :post
    end

    def output_path(site, parent_path)
      File.join(parent_path, self.class.path, @slug)
    end
  end
end