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
    attr_reader :archive
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
    rescue PublishingError, RenderingError, GenerationError => e
      @errors << e
    end

    def data
      @config.data || {}
    end

    def inspect
      "#<#{self.class} @paths=#{paths}>"
    end

    private

    def prepare
      @archive = Dimples::Archive.new

      @categories = {}
      @templates = {}

      @pages = []
      @posts = []
      @errors = []

      @latest_post = nil
    end

    def read_files(path)
      Dir[File.join(path, '**', '*.*')].sort
    end

    def read_templates
      @templates = {}

      read_files(@paths[:templates]).each do |path|
        basename = File.basename(path, File.extname(path))
        dir_name = File.dirname(path)

        unless dir_name == @paths[:templates]
          basename = dir_name.split(File::SEPARATOR)[-1] + '.' + basename
        end

        @templates[basename] = Template.new(self, path)
      end
    end

    def read_posts
      @posts = read_files(@paths[:posts]).map do |path|
        Post.new(self, path).tap do |post|
          @archive.add_post(post)
          categorise_post(post)
        end
      end.reverse

      @latest_post = @posts[0]
    end

    def read_pages
      @pages = read_files(@paths[:pages]).map { |path| Page.new(self, path) }
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
        FileUtils.rm_r(@paths[:destination], secure: true)
      else
        FileUtils.mkdir_p(@paths[:destination])
      end
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

      Dimples::Pager.paginate(
        self,
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
      @archive.years.each do |year|
        publish_archive(year)
        next unless @config.generation.month_archives

        @archive.months(year).each do |month|
          publish_archive(year, month)
          next unless @config.generation.day_archives

          @archive.days(year, month).each do |day|
            publish_archive(year, month, day)
          end
        end
      end
    end

    def publish_archive(year, month = nil, day = nil)
      date_type = if day
                    'day'
                  elsif month
                    'month'
                  else
                    'year'
                  end

      posts = @archive.posts_for_date(year, month, day)

      date_parts = [year, month, day].compact
      path = File.join(@paths[:destination], @config.paths.archives, date_parts)
      layout = @config.layouts.date_archive

      data = {
        page: {
          title: posts[0].date.strftime(@config.date_formats[date_type]),
          archive_date: posts[0].date,
          archive_type: date_type
        }
      }

      Dimples::Pager.paginate(self, posts.reverse, path, layout, data)
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

        Dimples::Pager.paginate(
          self,
          category_posts,
          path,
          @config.layouts.category,
          context
        )

        publish_feeds(category_posts, path, context)
      end
    end

    def publish_feeds(posts, path, context = {})
      @config.feed_formats.each do |format|
        feed = Feed.new(self, format)

        feed.feed_posts = posts.slice(0, @config.pagination.per_page)
        feed.write(path, context)
      end
    end
  end
end
