module Salt
  class Page
    include Frontable
    include Publishable

    attr_accessor :path
    attr_accessor :title
    attr_accessor :filename
    attr_accessor :extension
    attr_accessor :layout

    attr_writer :contents

    def initialize(site, path = nil)
      @site = site
      
      if path
        @path = path
        @contents = read_with_yaml(path)
        @filename = File.basename(path, File.extname(path))
      else
        @filename = 'index'
      end

      @extension = @site.config['file_extensions']['pages']
      @layout ||= @site.config['layouts']['page']
    end

    def type
      :page
    end

    def contents
      @contents
    end

    def output_file_path(parent_path)
      parts = [parent_path]

      parts << File.dirname(@path).gsub(@site.source_paths[:pages], '') unless @path.nil?
      parts << "#{@filename}.#{@extension}"

      File.join(parts)
    end
  end
end