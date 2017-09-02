# frozen_string_literal: true

module Dimples
  # A class that models a single site.
  class Site
    include Pagination

    attr_accessor :source_paths
    attr_accessor :output_paths
    attr_accessor :config
    attr_accessor :templates
    attr_accessor :categories
    attr_accessor :archives
    attr_accessor :pages
    attr_accessor :posts
    attr_accessor :latest_post
    attr_accessor :post_class
    attr_accessor :errors

    def initialize(config)
      @config = config

      @templates = {}
      @categories = {}
      @pages = []
      @posts = []
      @errors = []

      @archives = { year: {}, month: {}, day: {} }
      @latest_post = false

      @post_class = @config.class_override(:post) || Dimples::Post

      @source_paths = { root: File.expand_path(@config['source_path']) }
      @output_paths = { site: File.expand_path(@config['destination_path']) }

      %w[pages posts public templates].each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      %w[archives posts categories].each do |path|
        output_path = File.join(@output_paths[:site], @config['paths'][path])
        @output_paths[path.to_sym] = output_path
      end
    end

    def generate
      scan_files
      prepare_output_directory

      generate_pages unless @pages.count.zero?

      unless @posts.count.zero?
        generate_posts
        generate_archives
        generate_categories if @config['generation']['categories']
      end

      copy_assets
    rescue Errors::RenderingError,
           Errors::PublishingError,
           Errors::GenerationError => e
      @errors << e.message
    end

    def generated?
      @errors.count.zero?
    end

    def scan_files
      Dimples.logger.debug('Scanning files...') if @config['verbose_logging']

      scan_templates
      scan_pages
      scan_posts
    end

    def scan_templates
      Dir.glob(File.join(@source_paths[:templates], '**', '*.*')).each do |path|
        template = Dimples::Template.new(self, path)

        parent_path = File.dirname(path)
        if parent_path == @source_paths[:templates]
          slug = template.slug
        else
          relative_path = parent_path.sub(@source_paths[:templates], '')[1..-1]
          slug = relative_path.sub(File::SEPARATOR, '.') + ".#{template.slug}"
        end

        @templates[slug] = template
      end
    end

    def scan_pages
      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        @pages << scan_page(path)
      end
    end

    def scan_page(path)
      Dimples::Page.new(self, path)
    end

    def scan_posts
      Dir.glob(File.join(@source_paths[:posts], '*.*')).reverse_each do |path|
        @posts << scan_post(path)
      end

      @posts.each_index do |index|
        if (index - 1) >= 0
          @posts[index].next_post = @posts.fetch(index - 1, nil)
        end

        if (index + 1) < @posts.count
          @posts[index].previous_post = @posts.fetch(index + 1, nil)
        end
      end

      @latest_post = @posts.first
    end

    def scan_post(path)
      @post_class.new(self, path).tap do |post|
        post.categories&.each do |slug|
          @categories[slug] ||= Dimples::Category.new(self, slug)
          @categories[slug].posts << post
        end

        archive_year(post.year) << post
        archive_month(post.year, post.month) << post
        archive_day(post.year, post.month, post.day) << post
      end
    end

    def prepare_output_directory
      if Dir.exist?(@output_paths[:site])
        FileUtils.remove_dir(@output_paths[:site])
      end

      Dir.mkdir(@output_paths[:site])
    rescue => e
      error_message = "Couldn't prepare the output directory (#{e.message})"
      raise Errors::GenerationError, error_message
    end

    def generate_posts
      if @config['verbose_logging']
        Dimples.logger.debug_generation('posts', @posts.length)
      end

      @posts.each(&:write)

      paginate(
        self,
        @posts,
        @output_paths[:archives],
        @config['layouts']['posts']
      )

      generate_posts_feeds if @config['generation']['feeds']
    end

    def generate_pages
      if @config['verbose_logging']
        Dimples.logger.debug_generation('pages', @pages.length)
      end

      @pages.each(&:write)
    end

    def generate_categories
      if @config['verbose_logging']
        Dimples.logger.debug_generation('category pages', @categories.length)
      end

      @categories.each_value do |category|
        path = File.join(@output_paths[:categories], category.slug)

        options = {
          context: { category: category.slug },
          title: category.name
        }

        paginate(
          self,
          category.posts,
          path,
          @config['layouts']['category'],
          options
        )
      end

      generate_category_feeds if @config['generation']['category_feeds']
    end

    def generate_archives
      %w[year month day].each do |date_type|
        next unless @config['generation']["#{date_type}_archives"]

        @archives[date_type.to_sym].each do |date, posts|
          year, month, day = date.split('-')

          dates = { year: year }
          dates[:month] = month if month
          dates[:day] = day if day

          path = File.join(@output_paths[:archives], dates.values)
          layout = @config['layouts']["#{date_type}_archives"]

          options = {
            context: dates,
            title: posts[0].date.strftime(@config['date_formats'][date_type])
          }

          paginate(self, posts, path, layout, options)
        end
      end
    end

    def generate_feeds(path, context)
      feed_templates.each do |format|
        next unless @templates[format]

        feed = Dimples::Page.new(self)

        feed.output_directory = path
        feed.filename = 'feed'
        feed.extension = @templates[format].slug
        feed.layout = format

        feed.write(context)
      end
    end

    def generate_posts_feeds
      posts = @posts[0..@config['pagination']['per_page'] - 1]
      generate_feeds(@output_paths[:site], posts: posts)
    end

    def generate_category_feeds
      @categories.each_value do |category|
        path = File.join(@output_paths[:categories], category.slug)
        posts = category.posts[0..@config['pagination']['per_page'] - 1]

        generate_feeds(path, posts: posts, category: category.slug)
      end
    end

    def feed_templates
      @feed_templates ||= @templates.keys.select { |k| k =~ /^feeds\./ }
    end

    def copy_assets
      if Dir.exist?(@source_paths[:public])
        Dimples.logger.debug('Copying assets...') if @config['verbose_logging']

        path = File.join(@source_paths[:public], '.')
        FileUtils.cp_r(path, @output_paths[:site])
      end
    rescue => e
      raise Errors::GenerationError, "Site assets failed to copy (#{e.message})"
    end

    def inspect
      "#<#{self.class} " \
      "@source_paths=#{@source_paths} " \
      "@output_paths=#{@output_paths}>"
    end

    private

    def archive_year(year)
      @archives[:year][year] ||= []
    end

    def archive_month(year, month)
      @archives[:month]["#{year}-#{month}"] ||= []
    end

    def archive_day(year, month, day)
      @archives[:day]["#{year}-#{month}-#{day}"] ||= []
    end
  end
end
