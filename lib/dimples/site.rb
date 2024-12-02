# frozen_string_literal: true

require 'fileutils'
require 'tilt'
require 'date'
require 'yaml'

module Dimples
  # A class representing a single generated website.
  class Site
    attr_accessor :config

    def self.generate(config = {})
      new(config).generate
    end

    def initialize(config = {})
      @config = Config.new(config)
    end

    def generate
      prepare_output_directory

      generate_posts
      generate_categories
      generate_pages

      copy_assets
    end

    def posts
      @posts ||= Dir.glob(File.join(@config.source_paths[:posts], '**', '*.markdown')).map do |path|
        Dimples::Sources::Post.new(self, path)
      end.sort_by!(&:date).reverse!
    end

    def pages
      @pages ||= Dir.glob(File.join(@config.source_paths[:pages], '**', '*.erb')).map do |path|
        Dimples::Sources::Page.new(self, path)
      end
    end

    def layouts
      @layouts ||= Dir.glob(File.join(@config.source_paths[:layouts], '**', '*.erb')).to_h do |path|
        [File.basename(path, '.erb'), Dimples::Sources::Layout.new(self, path)]
      end
    end

    def categories
      @categories ||= {}.tap do |categories|
        posts.each do |post|
          post.categories.each do |category|
            categories[category] ||= []
            categories[category].append(post)
          end
        end
      end
    end

    def metadata
      @metadata ||= Metadata.new(posts: posts, categories: categories)
    end

    private

    def generate_posts
      posts.each(&:write)
      Pager.paginate(self, @config.build_paths[:posts].gsub(@config.build_paths[:root], '').concat('/'), posts)
      generate_feed(@config.build_paths[:root], posts)
    end

    def generate_categories
      categories.each do |category, posts|
        metadata = { title: category.capitalize, category: category }
        Pager.paginate(self, "/categories/#{category}/", posts, metadata)
        generate_feed(File.join(@config.build_paths[:root], 'categories', category), posts)
      end
    end

    def generate_pages
      pages.each(&:write)
    end

    def generate_feed(output_path, posts)
      return if layouts['feed'].nil?

      layouts['feed'].write(
        File.join(output_path, 'feed.atom'),
        posts: posts.slice(0, 10)
      )
    end

    def prepare_output_directory
      if Dir.exist?(@config.build_paths[:root])
        raise "The site directory (#{@config.build_paths[:root]}) already exists."
      end

      Dir.mkdir(@config.build_paths[:root])
    end

    def copy_assets
      return unless Dir.exist?(@config.source_paths[:static])

      FileUtils.cp_r(File.join(@config.source_paths[:static], '.'), @config.build_paths[:root])
    end
  end
end
