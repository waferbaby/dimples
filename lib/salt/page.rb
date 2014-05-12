module Salt
  class Page
    include Frontable
    include Renderable

    attr_accessor :path, :title, :contents, :filename, :extension, :layout

    def initialize(site, path = nil)
      @site = site
      @path = path
      @title = false
      @extension = 'html'

      if path
        @contents = read_with_yaml(path)
        @filename = File.basename(path, File.extname(path))
      else
        @contents = ''
        @filename = 'index'
      end
    end

    def type
      :page
    end

    def output_file
      "#{filename}.#{extension}"
    end

    def output_path(parent_path)
      return parent_path if @path.nil?

      File.join(parent_path, File.dirname(@path).gsub(@site.source_paths[:pages], ''))
    end

    def write(path, context = false)
      directory_path = output_path(path)
      full_path = File.join(directory_path, output_file)

      @url = full_path.gsub(@site.output_paths[:site], '').gsub(/index\.html$/, '')
      
      contents = if context
        render(@site, @contents, {this: self}.merge(context))
      else
        @contents
      end

      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)

      File.open(full_path, 'w') do |file|
        file.write(contents)
      end
    end
  end
end