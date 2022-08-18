# frozen_string_literal: true

require_relative 'pager'

require 'tilt'

module Dimples
  class Site
    def self.generate(output_path)
      new(output_path).generate
    end

    attr_accessor :posts, :archives, :categories

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
      generate_archives
    end

    private

    def read_files(path)
      Dir[File.join(path, '**', '*.*')].sort
    end

    def scan_posts
      @archives = {}
      @categories = {}

      @posts = read_files(@paths[:posts]).map do |path|
        post = Dimples::Post.new(path)

        year = post.date.year
        month = post.date.strftime('%m')

        @archives[year] ||= {}
        @archives[year][month] ||= []
        @archives[year][month] << post

        post
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

    def generate_file(path, content)
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
        generate_file(File.join(page_path, page.filename), render(page, context))
      end
    end

    def generate_posts
      directory_path = File.join(@paths[:destination], 'posts')
      Dir.mkdir(directory_path)

      @posts.each do |post|
        path = File.join(directory_path, post.slug, post.filename)
        generate_file(path, render(post, post: post))
      end
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

        generate_file(File.join(path, page.filename), render(page, page: page))
      end
    end

    def generate_archives
      archives_path = File.join(@paths[:destination], 'archives')

      @archives.each do |year, months|
        year_path = File.join(archives_path, year.to_s)
        generate_paginated_posts(months.values.flatten, year_path, year: year)

        months.each do |month, posts|
          generate_paginated_posts(posts, File.join(year_path, month), year: year, month: month)
        end
      end
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
