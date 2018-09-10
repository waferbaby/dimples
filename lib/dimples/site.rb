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
    attr_reader :archives
    attr_reader :templates
    attr_reader :latest_post

    def initialize(config = {})
      @config = Hashie::Mash.new(Configuration.defaults).deep_merge(config)

      @paths = {}.tap do |paths|
        paths[:source] = File.expand_path(@config.source)
        paths[:destination] = File.expand_path(@config.destination)

        %w[pages posts static templates].each do |type|
          paths[type.to_sym] = File.join(paths[:source], type)
        end
      end

      prepare
    end

    def generate
      prepare

      read_templates
      read_posts
      read_pages

      create_output_directory
      copy_static_assets

      publish_posts
      publish_pages
      publish_archives if @config.generation.year_archives
      publish_categories if @config.generation.categories
    rescue PublishingError, RenderingError, GenerationError => error
      @errors << error
    end

    def data
      @config.data || {}
    end

    def inspect
      "#<#{self.class} @paths=#{paths}>"
    end

    private

    def prepare
      @archives = { year: {} }

      @categories = {}
      @templates = {}

      @pages = []
      @posts = []
      @errors = []

      @latest_post = nil
    end

    def read_templates
      @templates = {}
      template_glob = File.join(@paths[:templates], '**', '*.*')

      Dir.glob(template_glob).each do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      post_glob = File.join(@paths[:posts], '**', '*.*')

      @posts = Dir.glob(post_glob).sort.map do |path|
        Post.new(self, path).tap do |post|
          add_archive_post(post)
          categorise_post(post)
        end
      end.reverse

      @latest_post = @posts[0]
    end

    def read_pages
      page_glob = File.join(@paths[:pages], '**', '*.*')
      @pages = Dir.glob(page_glob).sort.map { |path| Page.new(self, path) }
    end

    def add_archive_post(post)
      archive_year(post.year)[:posts] << post
      archive_month(post.year, post.month)[:posts] << post
      archive_day(post.year, post.month, post.day)[:posts] << post
    end

    def categorise_post(post)
      post.categories.each do |slug|
        slug_sym = slug.to_sym

        @categories[slug_sym] ||= Category.new(self, slug)
        @categories[slug_sym].posts << post
      end
    end

    def create_output_directory
      if Dir.exist?(@paths[:destination])
        FileUtils.remove_dir(@paths[:destination])
      end

      FileUtils.mkdir_p(@paths[:destination])
    rescue StandardError => e
      message = "Couldn't prepare the output directory (#{e.message})"
      raise GenerationError, message
    end

    def copy_static_assets
      return unless Dir.exist?(@paths[:static])
      FileUtils.cp_r(File.join(@paths[:static], '.'), @paths[:destination])
    rescue StandardError => e
      raise GenerationError, "Failed to copy site assets (#{e.message})"
    end

    def publish_posts
      @posts.each do |post|
        path = File.join(
          @paths[:destination],
          post.date.strftime(@config.paths.posts),
          post.slug
        )

        post.write(path)
      end

      if @config.generation.main_feed
        publish_feeds(@posts, @paths[:destination])
      end

      return unless @config.generation.paginated_posts

      paginate_posts(
        @posts,
        File.join(@paths[:destination], @config.paths.paginated_posts),
        @config.layouts.paginated_post
      )
    end

    def publish_pages
      @pages.each do |page|
        path = if page.path
                 File.dirname(page.path).sub(
                   @paths[:pages],
                   @paths[:destination]
                 )
               else
                 @paths[:destination]
               end

        page.write(path)
      end
    end

    def publish_archives
      @archives[:year].each do |year, year_archive|
        publish_date_archive(year)
        next unless @config.generation.month_archives

        year_archive[:month].each do |month, month_archive|
          publish_date_archive(year, month)
          next unless @config.generation.day_archives

          month_archive[:day].each_key do |day|
            publish_date_archive(year, month, day)
          end
        end
      end
    end

    def publish_date_archive(year, month = nil, day = nil)
      date_type = if day
                    'day'
                  elsif month
                    'month'
                  else
                    'year'
                  end

      date_parts = [year, month, day].compact
      path = File.join(@paths[:destination], @config.paths.archives, date_parts)

      posts = archive(year, month, day)[:posts]

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

    def publish_categories
      @categories.each_value do |category|
        path = File.join(
          @paths[:destination],
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
        path.sub(@paths[:destination], '') + '/',
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

    def archive(year, month = nil, day = nil)
      if day
        archive_day(year, month, day)
      elsif month
        archive_month(year, month)
      else
        archive_year(year)
      end
    end

    def archive_year(year)
      @archives[:year][year.to_s] ||= { month: {}, posts: [] }
    end

    def archive_month(year, month)
      archive_year(year)[:month][month.to_s] ||= { day: {}, posts: [] }
    end

    def archive_day(year, month, day)
      archive_month(year, month)[:day][day.to_s] ||= { posts: [] }
    end
  end
end
