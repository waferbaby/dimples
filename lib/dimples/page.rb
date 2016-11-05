module Dimples
  class Page
    include Frontable
    include Writeable
    include Renderable

    attr_accessor :path
    attr_accessor :title
    attr_accessor :template
    attr_accessor :filename
    attr_accessor :extension
    attr_accessor :layout
    attr_accessor :contents
    attr_accessor :rendered_contents

    def initialize(site, path = nil)
      @site = site
      @extension = @site.config['file_extensions']['pages']
      @path = path

      if @path
        @filename = File.basename(@path, File.extname(@path))
        @contents = read_with_yaml(@path)
      else
        @filename = 'index'
        @contents = ''
      end
    end

    def output_path(parent_path)
      parts = [parent_path]

      unless @path.nil?
        parts << File.dirname(@path).gsub(@site.source_paths[:pages], '')
      end

      parts << "#{@filename}.#{@extension}"

      File.join(parts)
    end
  end
end
