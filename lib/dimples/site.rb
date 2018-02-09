# frozen_string_literal: true

module Dimples
  class Site
    attr_accessor :config
    attr_accessor :categories
    attr_accessor :errors
    attr_accessor :paths

    def initialize(config = {})
      @config = Hashie::Mash.new(Configuration.defaults).deep_merge(config)
      @categories = {}
      @errors = []

      @paths = {}.tap do |paths|
        paths[:source] = Dir.pwd
        paths[:output] = File.join(paths[:source], 'site')

        %w[posts pages templates].each do |type|
          paths[type.to_sym] = File.join(paths[:source], type)
        end
      end
    end

    def generate
      prepare_output_directory

      posts.each do |post|
        Plugin.process(self, :post_write, post) { post.write }
      end

      pages.each do |page|
        Plugin.process(self, :page_write, page) { page.write }
      end
    rescue PublishingError, RenderingError, GenerationError => error
      @errors << error
    end

    def templates
      @templates ||= {}.tap do |templates|
        globbed_files(@paths[:templates]).each do |path|
          basename = File.basename(path, File.extname(path))
          dir_name = File.dirname(path)

          unless dir_name == @paths[:templates]
            basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
          end

          templates[basename] = Template.new(self, path)
        end
      end
    end

    def posts
      @posts ||= globbed_files(@paths[:posts]).sort.map do |path|
        Post.new(self, path)
      end
    end

    def pages
      @pages ||= globbed_files(@paths[:pages]).sort.map do |path|
        Page.new(self, path)
      end
    end

    def inspect
      "#<#{self.class} @paths=#{@paths}>"
    end

    private

    def prepare_output_directory
      FileUtils.remove_dir(@paths[:output]) if Dir.exist?(@paths[:output])
      Dir.mkdir(@paths[:output])
    rescue StandardError => e
      message = "Couldn't prepare the output directory (#{e.message})"
      raise GenerationError, message
    end

    def globbed_files(path)
      Dir.glob(File.join(path, '**', '*.*'))
    end
  end
end
