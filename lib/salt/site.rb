module Salt
  class Site
    attr_accessor :paths, :templates, :pages, :posts

    def self.instance()
      @site ||= new
    end

    def initialize()
      @paths, @templates, @pages, @posts = {}, {}, [], []

      @klasses = {
        page: Salt::Page,
        post: Salt::Post,
      }

    end

    def register(klass)
      if klass.superclass == Salt::Page
        @klasses[:page] = klass
      elsif klass.superclass == Salt::Post
        @klasses[:post] = klass
      end
    end

    def setup(config = {})
      @paths[:source] = File.expand_path(config[:source]) || Dir.pwd

      %w{pages posts templates site}.each do |path|
        path_symbol = path.to_sym
        @paths[path_symbol] = File.join(@paths[:source], config[path_symbol] || path)
      end
    end

    def scan_files()
      Dir.glob(File.join(@paths[:templates], '*.*')).each do |path|
        template = Salt::Template.new(path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(path)
      end

      Dir.glob(File.join(@paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(path)
      end
    end

    def generate()
      self.scan_files()
    end

    private
      attr_accessor :klasses
  end
end