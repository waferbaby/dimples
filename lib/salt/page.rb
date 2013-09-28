module Salt
  class Page
    include Frontable

    attr_accessor :path, :contents, :layout, :filename, :extension

    def initialize(path = nil)
      @path = path

      if path
        @contents = read_with_yaml(path)
        @filename = File.basename(path, File.extname(path))
      else
        @contents = ''
        @filename = 'index'
      end

      @extension = '.html'
      @layout = false
    end

    def render
      Site.instance.render_template(@layout, @contents)
    end

    def output_file
      "#{filename}#{extension}"
    end

    def output_path(parent_path)
      File.join(parent_path, File.dirname(@path).gsub(Site.instance.pages_path, ''))
    end

    def write(path)
      contents = self.render
      output_path = self.output_path(path)

      FileUtils.mkdir_p(output_path) unless Dir.exists?(output_path)

      full_path = File.join(output_path, self.output_file)

      if @path && File.exists?(full_path)
        return if File.mtime(@path) < File.mtime(full_path)
      end

      File.open(full_path, 'w') do |file|
        file.write(contents)
      end
    end
  end
end