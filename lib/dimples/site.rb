# frozen_string_literal: true

require_relative 'pager'

require 'fileutils'
require 'tilt'

module Dimples
  class Site
    def self.generate(output_path)
      new(output_path).generate
    end

    attr_accessor :posts, :categories

    def initialize(output_path)
      @paths = {
        source: File.expand_path(Dir.pwd),
        destination: File.expand_path(output_path)
      }

      %w[pages posts static templates].each do |type|
        @paths[type.to_sym] = File.join(@paths[:source], type)
      end

      scan_posts
      scan_pages
      scan_templates
    end

    def generate
      if Dir.exist?(@paths[:destination])
        puts "Error: The output directory (#{@paths[:destination]}) already exists."
        return
      end

      Dir.mkdir(@paths[:destination])

      generate_posts
      generate_pages
      generate_categories

      copy_assets
    end

    private

    def read_files(path)
      Dir[File.join(path, '**', '*.*')].sort
    end

    def scan_posts
      @posts = read_files(@paths[:posts]).map do |path|
        Dimples::Post.new(path)
      end

      @posts.sort_by! { |post| post.date }.reverse!

      @categories = {}

      @posts.each do |post|
        post.categories.each do |category|
          @categories[category] ||= []
          @categories[category] << post
        end
      end
    end

    def scan_pages
      @pages = read_files(@paths[:pages]).map do |path|
        Dimples::Page.new(path)
      end
    end

    def scan_templates
      @templates = {}.tap do |templates|
        read_files(@paths[:templates]).each do |path|
          key = File.basename(path, '.erb')
          templates[key] = Dimples::Template.new(path)
        end
      end
    end

    def write_file(path, content)
      directory_path = File.dirname(path)

      Dir.mkdir(directory_path) unless Dir.exist?(directory_path)
      File.write(path, content)
    end

    def generate_paginated_posts(posts, path, context = {})
      pager = Dimples::Pager.new(path.sub(@paths[:destination], '') + '/', posts)

      pager.each do |index|
        page = Dimples::Page.new()
        page.metadata[:layout] = 'posts'

        page_path = if index == 1
                      path
                    else
                      File.join(path, "page_#{index}")
                    end

        context.merge!(pagination: pager.to_context)
        write_file(File.join(page_path, page.filename), render(page, context))
      end
    end

    def generate_posts
      directory_path = File.join(@paths[:destination], 'posts')
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
        path = if page.path
                 File.dirname(page.path).sub(
                   @paths[:pages],
                   @paths[:destination]
                 )
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
      end
    end

    def generate_feed(posts, path)
      page = Dimples::Page.new()
      page.metadata[:layout] = 'feed'

      write_file(File.join(path, 'feed.atom'), render(page, posts: posts))
    end

    def copy_assets
      return unless Dir.exist?(@paths[:static])
      FileUtils.cp_r(File.join(@paths[:static], '.'), @paths[:destination])
    end

    def render(object, context = {}, content = nil)
      context[:site] ||= self

      output = object.render(context, content)

      if object.layout && @templates[object.layout]
        output = render(@templates[object.layout], context, output)
      end

      output
    end
  end
end
