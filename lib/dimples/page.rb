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
    attr_accessor :rendered_contents

    attr_writer :contents

    def initialize(site, path = nil)
      @site = site
      @extension = @site.config['file_extensions']['pages']

      if path
        @path = path
        @filename = File.basename(path, File.extname(path))
        @contents = read_with_yaml(path)
      else
        @path = nil
        @filename = 'index'
        @contents = ''
      end
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