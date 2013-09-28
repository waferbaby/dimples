module Salt
  class Site
    def self.instance
      @instance ||= new
    end

    def initialize
      @paths, @templates, @settings, @pages, @posts, @error = {}, {}, {}, [], [], nil

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
      @paths[:source] = File.expand_path(config[:source] || Dir.pwd)

      %w{pages posts templates site}.each do |path|
        path_symbol = path.to_sym
        @paths[path_symbol] = File.join(@paths[:source], path)

        self.class.instance_eval do
          define_method("#{path}_path") do
            @paths[path_symbol]
          end
        end
      end
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