module Dimples
  class Site
    attr_accessor :errors
    attr_accessor :paths
    attr_accessor :posts
    attr_accessor :templates

    def initialize(config = {})
      @templates = {}
      @posts = []
      @pages = []
      @errors = []

      @paths = Hash.new.tap do |paths|
        paths[:source] = Dir.pwd
        paths[:output] = File.join(paths[:source], 'public')

        %w(posts pages templates).each do |type|
          paths[type.to_sym] = File.join(paths[:source], type)
        end
      end
    end

    def generate
      begin
        read_templates
        read_posts
        read_pages

        publish_files
      rescue => e
        puts e
        puts e.backtrace
        # add to errors here.
      end

      true
    end

    private

    def read_templates
      Dir.glob(File.join(@paths[:templates], '**', '*.*')) do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + "." + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      path = File.join(@paths[:posts], '**', '*.*')
      @posts = Dir.glob(path).sort.map { |path| Post.new(self, path) }.reverse
    end

    def read_pages
      path = File.join(@paths[:pages], '**', '*.*')
      @pages = Dir.glob(path).sort.map { |path| Page.new(self, path) }
    end

    def publish_files
      @posts.each do |post|
        Filter.process(:post_write, post) { post.write }
      end

      @pages.each do |page|
        Filter.process(:page_write, page) { page.write }
      end
    end

    def inspect
      "#<#{self.class} @paths=#{@paths}>"
    end
  end
end