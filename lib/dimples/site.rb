# frozen_string_literal: true

require 'fileutils'
require 'tilt'
require 'date'

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
      @posts ||= Dir.glob(File.join(@config[:sources][:posts], '**', '*.markdown')).map do |path|
        Dimples::Sources::Post.new(self, path)
      end.sort_by!(&:date).reverse!
    end

    def pages
      @pages ||= Dir.glob(File.join(@config[:sources][:pages], '**', '*.erb')).map do |path|
        Dimples::Sources::Page.new(self, path)
      end
    end

    def layouts
      @layouts ||= Dir.glob(File.join(@config[:sources][:layouts], '**', '*.erb')).to_h do |path|
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
      @metadata ||= { posts: posts, categories: categories }
    end

    private

    def generate_posts
      posts.each(&:write)
      Pager.paginate(self, '/interviews/', posts)

      layouts['feed'].write(
        File.join(@config[:output][:root], 'feed.atom'),
        posts: posts.slice(0, 10)
      )
    end

    def generate_categories
      categories.each do |category, posts|
        metadata = { title: category.capitalize, category: category }
        Pager.paginate(self, "/categories/#{category}/", posts, metadata)

        layouts['feed'].write(
          File.join(@config[:output][:root], 'categories', category, 'feed.atom'),
          posts: posts.slice(0, 10)
        )
      end
    end

    def generate_pages
      pages.each(&:write)
    end

    def prepare_output_directory
      raise "The site directory (#{@config[:output][:root]}) already exists." if Dir.exist?(@config[:output][:root])

      Dir.mkdir(@config[:output][:root])
    end

    def copy_assets
      return unless Dir.exist?(@config[:sources][:static])

      FileUtils.cp_r(File.join(@config[:sources][:static], '.'), @config[:output][:root])
    end
  end
end
