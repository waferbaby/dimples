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

    private

    def posts
      @posts ||= Dir.glob(File.join(@config[:sources][:posts], '**', '*.markdown')).map do |path|
        Dimples::Post.new(path, @config)
      end.sort_by!(&:date).reverse!
    end

    def pages
      @pages ||= Dir.glob(File.join(@config[:sources][:pages], '**', '*.erb')).map do |path|
        Dimples::Page.new(path, @config)
      end
    end

    def layouts
      @layouts ||= Dir.glob(File.join(@config[:sources][:layouts], '**', '*.erb')).to_h do |path|
        [File.basename(path, '.erb'), Dimples::Layout.new(path, @config)]
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

    def generate_posts
      posts.each do |post|
        write_item(post)
      end

      Pager.paginate('/interviews/', posts, @config) do |pagination|
        path = File.join(@config[:output][:root], pagination[:urls][:current_page])
        write_item(layouts['posts'], output_path: path, metadata: { pagination: pagination })
      end
    end

    def generate_categories
      categories.each do |category, posts|
        Pager.paginate("/categories/#{category}/", posts, @config) do |pagination|
          path = File.join(@config[:output][:root], pagination[:urls][:current_page])
          metadata = { title: category.capitalize, category: category, pagination: pagination }

          write_item(layouts['posts'], output_path: path, metadata: metadata)
        end
      end
    end

    def generate_pages
      pages.each do |page|
        write_item(page)
      end
    end

    def write_item(item, output_path: nil, metadata: {})
      output_path ||= item.output_directory

      FileUtils.mkdir_p(output_path) unless File.directory?(output_path)

      contents = render_item(item, metadata: metadata)
      File.write(File.join(output_path, item.filename), contents)
    end

    def render_item(item, body: nil, metadata: {})
      metadata = item.metadata.merge(metadata)
      output = item.template.render(metadata_context(metadata)) { body }
      return output unless item.layout && layouts[item.layout]

      render_item(layouts[item.layout], body: output, metadata: metadata)
    rescue StandardError => e
      raise "Failed to render #{item.path}: #{e}"
    end

    def metadata_context(metadata)
      Object.new.tap do |context|
        shared_metadata.merge(metadata).each do |key, value|
          context.instance_variable_set("@#{key}", value)
        end
      end
    end

    def shared_metadata
      @shared_metadata ||= {
        posts: posts,
        categories: categories
      }
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
