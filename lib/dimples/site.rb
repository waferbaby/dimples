# frozen_string_literal: true

module Dimples
  class Site
    attr_reader :config
    attr_reader :categories
    attr_reader :errors
    attr_reader :paths
    attr_reader :posts
    attr_reader :pages
    attr_reader :templates

    def initialize(config = {})
      @config = Hashie::Mash.new(Configuration.defaults).deep_merge(config)

      @paths = {}.tap do |paths|
        paths[:source] = Dir.pwd
        paths[:output] = File.join(paths[:source], 'site')

        %w[posts pages templates].each do |type|
          paths[type.to_sym] = File.join(paths[:source], type)
        end
      end

      prepare
    end

    def generate
      prepare

      read_templates
      read_posts
      read_pages

      create_output_directory

      publish
    rescue PublishingError, RenderingError, GenerationError => error
      @errors << error
    end

    def inspect
      "#<#{self.class} @paths=#{@paths}>"
    end

    private

    def prepare
      @categories = {}
      @templates = {}

      @pages = []
      @posts = []
      @errors = []
    end

    def create_output_directory
      FileUtils.remove_dir(@paths[:output]) if Dir.exist?(@paths[:output])
      Dir.mkdir(@paths[:output])
    rescue StandardError => e
      message = "Couldn't prepare the output directory (#{e.message})"
      raise GenerationError, message
    end

    def read_templates
      @templates = {}

      globbed_files(@paths[:templates]).each do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      @posts = globbed_files(@paths[:posts]).sort.map do |path|
        Post.new(self, path)
      end.reverse
    end

    def read_pages
      @pages = globbed_files(@paths[:pages]).sort.map do |path|
        Page.new(self, path)
      end
    end

    def publish
      @posts.each do |post|
        Plugin.process(self, :post_write, post) { post.write }
      end

      @pages.each do |page|
        Plugin.process(self, :page_write, page) { page.write }
      end
    end

    def globbed_files(path)
      Dir.glob(File.join(path, '**', '*.*'))
    end
  end
end
