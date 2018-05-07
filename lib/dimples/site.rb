# frozen_string_literal: true

module Dimples
  # A collection of pages, posts and templates that can generate a website.
  class Site
    attr_reader :config
    attr_reader :categories
    attr_reader :errors
    attr_reader :paths
    attr_reader :posts
    attr_reader :pages
    attr_reader :templates
    attr_reader :latest_post

    def initialize(config = {})
      @config = Hashie::Mash.new(Configuration.defaults).deep_merge(config)

      @paths = {}.tap do |paths|
        paths[:base] = Dir.pwd
        paths[:output] = File.expand_path(@config.paths.output)

        paths[:sources] = {}.tap do |sources|
          %w[pages posts static templates].each do |type|
            sources[type.to_sym] = File.join(paths[:base], type)
          end
        end
      end

      prepare
    end

    def generate
      prepare
      scan_sources
      create_output_directory
      copy_static_assets
      publish_files
    rescue PublishingError, RenderingError, GenerationError => error
      @errors << error
    end

    def scan_sources
      trigger_event(:before_file_scanning)

      read_templates
      read_posts
      read_pages

      trigger_event(:after_file_scanning)
    end

    def publish_files
      trigger_event(:before_publishing)

      publish_posts
      publish_pages
      publish_archives
      publish_categories if @config.generation.categories

      trigger_event(:after_publishing)
    end

    def inspect
      "#<#{self.class} @paths=#{paths}>"
    end

    private

    def prepare
      @archives = { year: {}, month: {}, day: {} }

      @categories = {}
      @templates = {}

      @pages = []
      @posts = []
      @errors = []

      @latest_post = nil
    end

    def read_templates
      @templates = {}
      template_glob = File.join(@paths[:sources][:templates], '**', '*.*')

      Dir.glob(template_glob).each do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:sources][:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      post_glob = File.join(@paths[:sources][:posts], '**', '*.*')

      @posts = Dir.glob(post_glob).sort.map do |path|
        Post.new(self, path).tap do |post|
          add_archive_post(post)
          categorise_post(post)
        end
      end.reverse

      @latest_post = @posts[0]
    end

    def read_pages
      page_glob = File.join(@paths[:sources][:pages], '**', '*.*')
      @pages = Dir.glob(page_glob).sort.map { |path| Page.new(self, path) }
    end

    def add_archive_post(post)
      archive_year(post.year) << post
      archive_month(post.year, post.month) << post
      archive_day(post.year, post.month, post.day) << post
    end

    def categorise_post(post)
      post.categories.each do |slug|
        slug_sym = slug.to_sym

        @categories[slug_sym] ||= Category.new(self, slug)
        @categories[slug_sym].posts << post
      end
    end

    def create_output_directory
      FileUtils.remove_dir(@paths[:output]) if Dir.exist?(@paths[:output])
      Dir.mkdir(@paths[:output])
    rescue StandardError => e
      message = "Couldn't prepare the output directory (#{e.message})"
      raise GenerationError, message
    end

    def copy_static_assets
      return unless Dir.exist?(@paths[:sources][:static])
      FileUtils.cp_r(File.join(@paths[:sources][:static], '.'), @paths[:output])
    rescue StandardError => e
      raise GenerationError, "Failed to copy site assets (#{e.message})"
    end

    def publish_posts
      @posts.each do |post|
        trigger_event(:before_post_write, post)

        path = File.join(
          @paths[:output],
          post.date.strftime(@config.paths.posts),
          post.slug
        )

        post.write(path)

        trigger_event(:after_post_write, post)
      end

      publish_feeds(@posts, @paths[:output]) if @config.generation.main_feed
    end

    def publish_pages
      @pages.each do |page|
        trigger_event(:before_page_write, page)

        path = if page.path
                 File.dirname(page.path).sub(
                   @paths[:sources][:pages],
                   @paths[:output]
                 )
               else
                 @paths[:output]
               end

        page.write(path)

        trigger_event(:after_page_write, page)
      end
    end

    def publish_archives
      if @config.generation.archives
        paginate_posts(
          @posts,
          File.join(@paths[:output], @config.paths.archives),
          @config.layouts.archive
        )
      end

      %w[year month day].each do |date_type|
        next unless @config.generation["#{date_type}_archives"]
        publish_date_archive(date_type.to_sym)
      end
    end

    def publish_date_archive(date_type)
      @archives[date_type].each do |date, posts|
        date_parts = date.split('-')
        path = File.join(@paths[:output], @config.paths.archives, date_parts)

        paginate_posts(
          posts.reverse,
          path,
          @config.layouts.date_archive,
          page: {
            title: posts[0].date.strftime(@config.date_formats[date_type]),
            archive_date: posts[0].date,
            archive_type: date_type
          }
        )
      end
    end

    def publish_categories
      @categories.each_value do |category|
        path = File.join(
          @paths[:output],
          @config.paths.categories,
          category.slug
        )

        category_posts = category.posts.reverse
        context = { page: { title: category.name, category: category } }

        paginate_posts(
          category_posts,
          path,
          @config.layouts.category,
          context
        )

        publish_feeds(category_posts, path, context)
      end
    end

    def paginate_posts(posts, path, layout, context = {})
      pager = Pager.new(
        path.sub(@paths[:output], '') + '/',
        posts,
        @config.pagination
      )

      pager.each do |index|
        page = Page.new(self)
        page.layout = layout

        page_prefix = @config.pagination.page_prefix
        page_path = if index == 1
                      path
                    else
                      File.join(path, "#{page_prefix}#{index}")
                    end

        page.write(
          page_path,
          context.merge(pagination: pager.to_context)
        )
      end
    end

    def publish_feeds(posts, path, context = {})
      @config.feed_formats.each do |feed_format|
        feed_layout = "feeds.#{feed_format}"
        next unless @templates.key?(feed_layout)

        page = Page.new(self)

        page.layout = feed_layout
        page.feed_posts = posts.slice(0, @config.pagination.per_page)
        page.filename = 'feed'
        page.extension = feed_format

        page.write(path, context)
      end
    end

    def archive_year(year)
      @archives[:year][year] ||= []
    end

    def archive_month(year, month)
      @archives[:month]["#{year}-#{month}"] ||= []
    end

    def archive_day(year, month, day)
      @archives[:day]["#{year}-#{month}-#{day}"] ||= []
    end

    def plugins
      @plugins ||= Plugin.subclasses&.map { |subclass| subclass.new(self) }
    end

    def trigger_event(event, item = nil)
      plugins.each do |plugin|
        plugin.process(event, item) if plugin.supports_event?(event)
      end
    end
  end
end
