# frozen_string_literal: true

module Dimples
  # A class that models a single site.
  class Site
    attr_accessor :source_paths
    attr_accessor :output_paths
    attr_accessor :config
    attr_accessor :templates
    attr_accessor :categories
    attr_accessor :archives
    attr_accessor :pages
    attr_accessor :posts
    attr_accessor :latest_post
    attr_accessor :page_class
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

      @page_class = @config.class_override(:page) || Dimples::Page
      @post_class = @config.class_override(:post) || Dimples::Post

      set_source_paths
      set_output_paths
    end

    def set_source_paths
      @source_paths = {
        root: File.expand_path(@config['source_path'])
      }

      %w[pages posts public templates].each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end
    end

    def set_output_paths
      @output_paths = {
        site: File.expand_path(@config['destination_path'])
      }

      %w[archives posts categories].each do |path|
        output_path = File.join(@output_paths[:site], @config['paths'][path])
        @output_paths[path.to_sym] = output_path
      end
    end

    def generate
      prepare_output_directory
      scan_files
      generate_files
      copy_assets
    rescue Errors::RenderingError,
           Errors::PublishingError,
           Errors::GenerationError => e
      @errors << e.message
    end

    def generated?
      @errors.count.zero?
    end

    private

    def prepare_output_directory
      if Dir.exist?(@output_paths[:site])
        FileUtils.remove_dir(@output_paths[:site])
      end

      Dir.mkdir(@output_paths[:site])
    rescue => e
      error_message = "Couldn't prepare the output directory (#{e.message})"
      raise Errors::GenerationError, error_message
    end

    def scan_files
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
          relative_path = parent_path.gsub(@source_paths[:templates], '')[1..-1]
          slug = relative_path.gsub(File::SEPARATOR, '.') + ".#{template.slug}"
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
      @page_class.new(self, path)
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
        post.categories.each do |slug|
          @categories[slug] ||= Dimples::Category.new(self, slug)
          @categories[slug].posts << post
        end

        add_post_to_archives(post)
      end
    end

    def add_post_to_archives(post)
      archive_year(post.year) << post
      archive_month(post.year, post.month) << post
      archive_day(post.year, post.month, post.day) << post
    end

    def archive_year(year)
      @archives[:year][year] ||= []
    end

    def archive_month(year, month)
      @archives[:month]["#{year}/#{month}"] ||= []
    end

    def archive_day(year, month, day)
      @archives[:day]["#{year}/#{month}/#{day}"] ||= []
    end

    def generate_files
      generate_pages unless @pages.count.zero?

      return if @posts.count.zero?

      generate_posts
      generate_archives
      generate_categories if @config['generation']['categories']
    end

    def generate_posts
      if @config['verbose_logging']
        Dimples.logger.debug_generation('posts', @posts.length)
      end

      @posts.each do |post|
        generate_post(post)
      end

      layout = @config['layouts']['posts']

      paginate(posts: @posts, path: @output_paths[:archives], layout: layout)

      generate_posts_feeds if @config['generation']['feeds']
    end

    def generate_post(post)
      post.write(post.output_path(@output_paths[:posts]))
    end

    def generate_pages
      if @config['verbose_logging']
        Dimples.logger.debug_generation('pages', @pages.length)
      end

      @pages.each do |page|
        generate_page(page)
      end
    end

    def generate_page(page)
      page.write(page.output_path(@output_paths[:site]))
    end

    def generate_categories
      if @config['verbose_logging']
        Dimples.logger.debug_generation('category pages', @categories.length)
      end

      @categories.each_value do |category|
        generate_category(category)
      end

      generate_category_feeds if @config['generation']['category_feeds']
    end

    def generate_category(category)
      params = {
        posts: category.posts,
        title: category.name,
        path: File.join(@output_paths[:categories], category.slug),
        layout: @config['layouts']['category'],
        context: { category: category.slug }
      }

      paginate(params)
    end

    def generate_archives
      %w[year month day].each do |date_type|
        if @config['generation']["#{date_type}_archives"]
          generate_archive_posts(date_type)
        end
      end
    end

    def generate_archive_posts(date_type)
      @archives[date_type.to_sym].each_value do |posts|
        post = posts[0]

        dates = case date_type
                when 'year'
                  { year: post.year }
                when 'month'
                  { year: post.year, month: post.month }
                when 'day'
                  { year: post.year, month: post.month, day: post.day }
                end

        params = {
          posts: posts,
          title: post.date.strftime(@config['date_formats'][date_type]),
          path: File.join(@output_paths[:archives], dates.values),
          layout: @config['layouts']["#{date_type}_archives"],
          context: dates
        }

        paginate(params)
      end
    end

    def generate_feeds(path, options)
      feed_templates.each do |format|
        next unless @templates[format]

        feed = @page_class.new(self)

        feed.filename = 'feed'
        feed.extension = format
        feed.layout = format

        feed.write(feed.output_path(path), options)
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

    def paginate(posts:, title: nil, path:, layout: false, context: {})
      per_page = @config['pagination']['per_page']
      pages = (posts.length.to_f / per_page.to_i).ceil
      url = path.gsub(@output_paths[:site], '') + '/'

      (1..pages).each do |index|
        page = @page_class.new(self)

        page.layout = layout
        page.title = title || @templates[layout].title

        output_path = File.join(path, index != 1 ? "page#{index}" : '')

        context[:posts] = posts.slice((index - 1) * per_page, per_page)
        context[:pagination] = build_pagination(index, pages, posts.count, url)

        page.write(page.output_path(output_path), context)
      end
    end

    def build_pagination(index, pages, item_count, url)
      pagination = {
        page: index,
        pages: pages,
        post_count: item_count,
        url: url
      }

      if (index - 1) > 0
        pagination[:previous_page] = index - 1
        pagination[:previous_page_url] = url

        if pagination[:previous_page] != 1
          page_string = "page#{pagination[:previous_page]}"
          pagination[:previous_page_url] += page_string
        end
      end

      if (index + 1) <= pages
        pagination[:next_page] = index + 1
        page_string = "#{url}page#{pagination[:next_page]}"
        pagination[:next_page_url] = page_string
      end

      pagination
    end
  end
end
