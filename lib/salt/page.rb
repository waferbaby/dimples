module Salt
  class Page
    include Frontable

    attr_accessor :path, :contents, :metadata, :filename, :extension

    def initialize(path = nil)
      @path = path
      @extension = '.html'

      if path
        @contents, @metadata = read_with_yaml(path)
        @filename = File.basename(path, File.extname(path))
      else
        @contents = ''
        @metadata = {}
        @filename = 'index'
      end
    end

    def render
      Site.instance.render_template(@metadata['layout'], @contents, @metadata)
    end

    def output_file(extension = nil)
      "#{self.filename}#{extension ? extension : self.extension}"
    end

    def output_path(parent_path)
      File.join(parent_path, File.dirname(@path).gsub(Site.instance.pages_path, ''))
    end

    def write(path, extension = nil)
      contents = self.render
      output_path = self.output_path(path)

      FileUtils.mkdir_p(output_path) unless Dir.exists?(output_path)

      full_path = File.join(output_path, self.output_file(extension))

      if @path && File.exists?(full_path)
        return if File.mtime(@path) < File.mtime(full_path)
      end

      File.open(full_path, 'w') do |file|
        file.write(contents)
      end
    end
  end
end