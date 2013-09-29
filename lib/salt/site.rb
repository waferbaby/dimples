module Salt
  class Site
    def initialize(path = nil)
      @paths, @templates, @pages, @posts = {}, {}, [], []

      @paths[:source] = path ? File.expand_path(path) : Dir.pwd
      @paths[:site] = File.join(@paths[:source], 'site')
      @paths[:pages] = File.join(@paths[:source], 'pages')
      @paths[:posts] = File.join(@paths[:source], 'posts')
      @paths[:templates] = File.join(@paths[:source], 'templates')

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

    def path(key)
      @paths[key]
    end

    def scan_files
      Dir.glob(File.join(@paths[:templates], '*.*')).each do |path|
        template = Salt::Template.new(self, path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(self, path)
      end

      Dir.glob(File.join(@paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(self, path)
      end

      @posts.reverse!
    end

    def render_template(key, contents, context = {})
      unless @templates.include?(key)
        return contents
      end

      @templates[key].render(contents, context)
    end

    def generate
      self.scan_files

      begin
        Dir.mkdir(@paths[:site]) unless Dir.exists?(@paths[:site])
      rescue Exception => e
        @error = "Failed to prepare the site directory (#{e})"
        return
      end

      begin
        @pages.each do |page|
          page.write(@paths[:site])
        end
      rescue Exception => e
        @error = "Failed to render a page (#{e})"
        return
      end

      begin
        @posts.each do |post|
          post.write(@paths[:site])
        end
      rescue Exception => e
        @error = "Failed to render a post (#{e})"
        return
      end
    end

    private
      attr_accessor :paths, :templates, :settings, :pages, :posts, :error, :klasses
  end
end