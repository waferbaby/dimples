module Salt
  class Post < Page
    attr_accessor :slug, :date, :categories, :year, :month, :day
    attr_writer :markdown

    def initialize(site, path)
      super

      parts = File.basename(path, File.extname(path)).match(/(\d{4})-(\d{2})-(\d{2})-(.+)/)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @filename = 'index'
      @layout = @site.config['layouts']['post']
      @categories ||= []

      @year = @date.strftime('%Y')
      @month = @date.strftime('%m')
      @day = @date.strftime('%d')
    end

    def type
      :post
    end

    def markdown
      @markdown ||= @site.markdown_engine.render(@contents)
    end

    def output_path(parent_path)

      parts = [parent_path]

      if @site.config['paths']['post']
        path = @date.strftime(@site.config['paths']['post'])
        parts.concat(path.split('/')) if path
      end

      parts << @slug

      File.join(parts)
    end
  end
end