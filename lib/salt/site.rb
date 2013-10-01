module Salt
  class Site
    def self.instance
      @site ||= new
    end

    def initialize
      @paths, @templates, @pages, @posts = {}, {}, [], []

      @klasses = {
        page: Salt::Page,
        post: Salt::Post,
      }
    end

    def setup(path = nil)
      @paths[:source] = path ? File.expand_path(path) : Dir.pwd
      @paths[:site] = File.join(@paths[:source], 'site')
      @paths[:pages] = File.join(@paths[:source], 'pages')
      @paths[:posts] = File.join(@paths[:source], 'posts')
      @paths[:templates] = File.join(@paths[:source], 'templates')
      @paths[:public] = File.join(@paths[:source], 'public')
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
        template = Salt::Template.new(path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(path)
      end

      Dir.glob(File.join(@paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(path)
      end

      @posts.reverse!
    end

    def render_template(key, contents, context = Object.new)
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
        puts "Failed to prepare the site directory (#{e})"
        return
      end

      begin
        @pages.each do |page|
          page.write(@paths[:site])
        end
      rescue Exception => e
        puts "Failed to render a page (#{e})"
        return
      end

      begin
        @posts.each do |post|
          post.write(@paths[:site])
        end
      rescue Exception => e
        puts "Failed to render a post (#{e})"
        return
      end

      begin
        if Dir.exists?(@paths[:public])
        end
      rescue Exception => e
      end
    end

    private
      attr_accessor :paths, :templates, :settings, :pages, :posts, :error, :klasses
  end
end