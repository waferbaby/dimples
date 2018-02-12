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
        paths[:base] = Dir.pwd
        paths[:output] = File.join(paths[:base], 'site')
        paths[:sources] = {}

        %w[pages posts public templates].each do |type|
          paths[:sources][type.to_sym] = File.join(paths[:base], type)
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
      copy_assets

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

    def read_templates
      @templates = {}

      globbed_files(@paths[:sources][:templates]).each do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:sources][:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      @posts = globbed_files(@paths[:sources][:posts]).sort.map do |path|
        Post.new(self, path).tap { |post| categorise_post(post) }
      end.reverse
    end

    def read_pages
      @pages = globbed_files(@paths[:sources][:pages]).sort.map do |path|
        Page.new(self, path)
      end
    end

    def categorise_post(post)
      post.categories.each do |slug|
        slug_sym = slug.to_sym

        @categories[slug_sym] ||= Category.new(self, slug)
        @categories[slug_sym].posts << post
      end
    end

    def create_output_directory
      FileUtils.remove_dir(@paths[:output]) if Dir.exist?(@paths[:output])
      Dir.mkdir(@paths[:output])
    rescue StandardError => e
      message = "Couldn't prepare the output directory (#{e.message})"
      raise GenerationError, message
    end

    def copy_assets
      return unless Dir.exist?(@paths[:sources][:public])
      FileUtils.cp_r(File.join(@paths[:sources][:public], '.'), @paths[:output])
    rescue StandardError => e
      raise GenerationError, "Failed to copy site assets (#{e.message})"
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
