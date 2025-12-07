# frozen_string_literal: true

require 'fileutils'
require 'tilt'
require 'date'
require 'yaml'

module Dimples
  # A class representing a single generated website.
  class Site
    attr_accessor :config

    def self.generate(config: {})
      new(config: config).generate
    end

    def initialize(config: {})
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
        Dimples::Entries::Post.new(site: self, path: path)
      end.sort_by!(&:date).reverse!
    end

    def pages
      @pages ||= Dir.glob(File.join(@config.source_paths[:pages], '**', '*.erb')).map do |path|
        Dimples::Entries::Page.new(site: self, path: path)
      end
    end

    def layouts
      @layouts ||= Dir.glob(File.join(@config.source_paths[:layouts], '**', '*.erb')).to_h do |path|
        [File.basename(path, '.erb'), Dimples::Entries::Layout.new(site: self, path: path)]
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
      posts.each { |post| generate_post(post) }

      Pager.paginate(
        site: self,
        url: @config.build_paths[:posts].gsub(@config.build_paths[:root], '').concat('/'),
        posts: posts
      )

      generate_feed(output_path: @config.build_paths[:root], posts: posts) if @config.generation[:main_feed]
    end

    def generate_post(post)
      post.write
    end

    def generate_pages
      pages.each { |page| generate_page(page) }
    end

    def generate_page(page)
      page.write
    end

    def generate_categories
      categories.each do |category, posts|
        metadata = { title: category.capitalize, category: category }

        Pager.paginate(
          site: self,
          url: "/categories/#{category}/",
          posts: posts,
          metadata: metadata
        )

        if @config.generation[:category_feeds]
          generate_feed(output_path: File.join(@config.build_paths[:root], 'categories', category), posts: posts)
        end
      end
    end

    def generate_feed(output_path:, posts:)
      return if layouts['feed'].nil?

      layouts['feed'].write(
        output_path: File.join(output_path, 'feed.atom'),
        metadata: { posts: posts.slice(0, 10) }
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
