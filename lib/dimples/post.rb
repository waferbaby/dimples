module Dimples
  class Post
    include Frontable
    include Writeable
    include Renderable

    attr_accessor :path
    attr_accessor :title
    attr_accessor :categories
    attr_accessor :template
    attr_accessor :filename
    attr_accessor :extension
    attr_accessor :layout
    attr_accessor :contents
    attr_accessor :slug
    attr_accessor :date
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day
    attr_accessor :rendered_contents
    attr_accessor :previous_post
    attr_accessor :next_post
    attr_accessor :draft

    def initialize(site, path)
      @site = site
      @path = path

      @filename = 'index'
      @extension = @site.config['file_extensions']['posts']

      date_format = /(\d{4})-(\d{2})-(\d{2})-(.+)/
      parts = File.basename(path, File.extname(path)).match(date_format)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @layout = @site.config['layouts']['post']
      @categories = {}

      @draft = false

      @year = @date.strftime('%Y')
      @month = @date.strftime('%m')
      @day = @date.strftime('%d')

      @contents = read_with_yaml(path)
    end

    def output_path(parent_path)
      parent_path = @date.strftime(parent_path) if parent_path =~ /%/
      File.join([parent_path, @slug, "#{@filename}.#{@extension}"])
    end
  end
end
