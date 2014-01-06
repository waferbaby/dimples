module Salt
  class Post < Page
    attr_accessor :slug, :date, :categories, :markdown

    def self.path
      "archives"
    end

    def initialize(path)
      super

      parts = File.basename(path, File.extname(path)).match(/(\d{4})-(\d{2})-(\d{2})-(.+)/)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @filename = 'index'
      @categories = []
      @layout = 'post'
    end

    def type
      :post
    end

    def contents
      site = Salt::Site.instance

      unless site.settings[:use_markdown]
        @contents
      else
        @markdown ||= Kramdown::Document.new(@contents, site.settings[:markdown_options]).to_html
      end
    end

    def output_path(site, parent_path)
      File.join(parent_path, self.class.path, @slug)
    end
  end
end