module Dimples
  class Post
    include Frontable
    include Publishable
    
    attr_accessor :path
    attr_accessor :title
    attr_accessor :template
    attr_accessor :filename
    attr_accessor :extension
    attr_accessor :layout
    attr_accessor :slug
    attr_accessor :date
    attr_accessor :categories
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day

    attr_writer :contents
    attr_writer :markdown

    def initialize(site, path)
      @site = site

      @path = path
      @contents = read_with_yaml(path)

      @filename = 'index'
      @extension = @site.config['file_extensions']['posts']

      parts = File.basename(path, File.extname(path)).match(/(\d{4})-(\d{2})-(\d{2})-(.+)/)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @layout ||= @site.config['layouts']['post']
      @categories ||= []

      @year = @date.strftime('%Y')
      @month = @date.strftime('%m')
      @day = @date.strftime('%d')
    end

    def type
      :post
    end

    def contents
      @contents
    end

    def markdown
      @markdown ||= @site.markdown_engine.render(contents())
    end

    def output_file_path(parent_path)
      parts = [parent_path]

      if @site.config['paths']['post']
        path = @date.strftime(@site.config['paths']['post'])
        parts.concat(path.split('/')) if path
      end

      parts << @slug
      parts << "#{@filename}.#{@extension}"

      File.join(parts)
    end
  end
end