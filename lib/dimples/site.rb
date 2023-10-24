# frozen_string_literal: true

require_relative 'pager'

require 'fileutils'
require 'tilt'
require 'date'

module Dimples
  class Site
    DEFAULT_CONFIG = { generation: { overwrite_directory: false }, paths: { posts: 'posts' } }.freeze

    def self.generate(source_path, output_path, config)
      new(source_path, output_path, config).generate
    end

    attr_accessor :posts, :pages, :categories, :config

    def initialize(source_path, output_path, config)
      @paths = {
        source: File.expand_path(source_path || Dir.pwd),
        destination: File.expand_path(output_path || File.join(Dir.pwd, 'site'))
      }

      @config = DEFAULT_CONFIG
      @config = @config.merge(config) if config.is_a?(Hash)

      %w[pages posts static templates].each do |type|
        @paths[type.to_sym] = File.join(@paths[:source], type)
      end

      scan_posts
      scan_pages
      scan_templates
    end

    def generate
      if Dir.exist?(@paths[:destination])
        unless @config.dig(:generation, :overwrite_directory)
          raise GenerationError, "The site directory (#{@paths[:destination]}) already exists."
        end

        FileUtils.rm_rf(@paths[:destination])
      end

      Dir.mkdir(@paths[:destination])

      generate_posts
      generate_pages
      generate_categories

      copy_assets
    end

    private

    def read_files(path)
      Dir[File.join(path, '**', '*.*')]
    end

    def scan_posts
      @posts = read_files(@paths[:posts]).map { |path| Dimples::Post.new(path) }
      @posts.sort_by!(&:date).reverse!

      @categories = {}

      @posts.each do |post|
        post.categories&.each do |category|
          @categories[category] ||= []
          @categories[category] << post
        end
      end
    end

    def scan_pages
      @pages = read_files(@paths[:pages]).map { |path| Dimples::Page.new(path) }
    end

    def scan_templates
      @templates =
        {}.tap do |templates|
          read_files(@paths[:templates]).each do |path|
            key = File.basename(path, '.erb')
            templates[key] = Dimples::Template.new(path)
          end
        end
    end

    def write_file(path, content)
      directory_path = File.dirname(path)

      FileUtils.mkdir_p(directory_path)
      File.write(path, content)
    end

    def generate_paginated_posts(posts, path, context = {})
      pager = Dimples::Pager.new("#{path.sub(@paths[:destination], '')}/", posts)

      pager.each do |index|
        page = Dimples::Page.new(nil, layout: 'posts')

        page_path =
          if index == 1
            path
          else
            File.join(path, "page_#{index}")
          end

        write_file(
          File.join(page_path, page.filename),
          render(page, context.merge!(pagination: pager.to_context))
        )
      end
    end

    def generate_posts
      directory_path = File.join(@paths[:destination], @config.dig(:paths, :posts))
      Dir.mkdir(directory_path)

      @posts.each do |post|
        path = File.join(directory_path, post.slug, post.filename)
        write_file(path, render(post, post: post))
      end

      generate_paginated_posts(@posts, directory_path)
      generate_feed(@posts.slice(0, 10), @paths[:destination])
    end

    def generate_pages
      @pages.each do |page|
        path =
          if page.path
            File.dirname(page.path).sub(@paths[:pages], @paths[:destination])
          else
            @paths[:destination]
          end

        write_file(File.join(path, page.filename), render(page, page: page))
      end
    end

    def generate_categories
      @categories.each do |category, posts|
        category_path = File.join(@paths[:destination], 'categories', category)

        generate_paginated_posts(posts, category_path, category: category)
        generate_feed(posts.slice(0, 10), category_path)
      end
    end

    def generate_feed(posts, path)
      page = Dimples::Page.new(nil, layout: 'feed')
      write_file(File.join(path, 'feed.atom'), render(page, posts: posts))
    end

    def copy_assets
      return unless Dir.exist?(@paths[:static])

      FileUtils.cp_r(File.join(@paths[:static], '.'), @paths[:destination])
    end

    def render(object, context = {}, content = nil)
      context[:site] ||= self

      output = object.render(context, content)

      output = render(@templates[object.layout], context, output) if object.layout &&
                                                                     @templates[object.layout]

      output
    end
  end
end
