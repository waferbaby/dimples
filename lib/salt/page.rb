module Salt
  class Page
    include Frontable
    include Renderable

    attr_accessor :path, :title, :contents, :filename, :extension, :layout

    def initialize(path = nil)
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

    def output_path(site, parent_path)
      return parent_path if @path.nil?

      File.join(parent_path, File.dirname(@path).gsub(site.source_paths[:pages], ''))
    end

    def write(site, path, context = {})
      directory_path = output_path(site, path)
      full_path = File.join(directory_path, output_file)

      @url = full_path.gsub(site.output_paths[:site], '').gsub(/index\.html$/, '')
      
      contents = render(site, @contents, {this: self}.merge(context))
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)

      File.open(full_path, 'w') do |file|
        file.write(contents)
      end
    end
  end
end