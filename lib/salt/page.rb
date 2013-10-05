module Salt
  class Page
    include Frontable
    include Renderable

    attr_accessor :path, :filename, :extension
    attr_writer :contents

    def initialize(path = nil)
      @path = path
      @extension = '.html'

      if path
        @contents = read_with_yaml(path)
        @filename = File.basename(path, File.extname(path))
      else
        @contents = ''
        @filename = 'index'
      end
    end

    def contents
      @contents
    end

    def output_file(extension = nil)
      "#{self.filename}#{extension ? extension : self.extension}"
    end

    def output_path(site, parent_path)
      return parent_path if @path.nil?
      File.join(parent_path, File.dirname(@path).gsub(site.path(:pages), ''))
    end

    def write(site, path, context = {}, extension = nil)
      contents = self.render(site, @contents, {this: self}.merge(context))
      output_path = self.output_path(site, path)

      FileUtils.mkdir_p(output_path) unless Dir.exists?(output_path)
      full_path = File.join(output_path, self.output_file(extension))

      File.open(full_path, 'w') do |file|
        file.write(contents)
      end
    end
  end
end