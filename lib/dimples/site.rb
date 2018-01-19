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
    attr_accessor :errors

    def initialize(config = {})
      @config = Dimples::Configuration.new(config)

      @templates = {}
      @categories = {}
      @pages = []
      @posts = []
      @errors = []

      @archives = { year: {}, month: {}, day: {} }
      @latest_post = false

      @source_paths = { root: File.expand_path(@config[:source_path]) }
      @output_paths = { site: File.expand_path(@config[:destination_path]) }

      %w[pages posts public templates].each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      %w[archives posts categories].each do |path|
        @output_paths[path.to_sym] = File.join(
          @output_paths[:site], @config[:paths][path.to_sym]
        )
      end
    end

    def generate
      scan_files
      prepare_output_directory

      publish_pages unless @pages.count.zero?

      unless @posts.count.zero?
        publish_posts
        publish_archives
        publish_categories if @config[:generation][:categories]
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
      Dimples.logger.debug('Scanning files...') if @config[:verbose_logging]

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
      paths = Dir.glob(File.join(@source_paths[:posts], '*.*')).sort

      paths.reverse_each do |path|
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
      post_class.new(self, path).tap do |post|
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
    rescue StandardError => e
      error_message = "Couldn't prepare the output directory (#{e.message})"
      raise Errors::GenerationError, error_message
    end

    def publish_posts
      if @config[:verbose_logging]
        Dimples.logger.debug_generation('posts', @posts.length)
      end

      @posts.each(&:write)

      paginate(
        self,
        @posts,
        @output_paths[:archives],
        @config[:layouts][:posts]
      )

      publish_posts_feeds if @config[:generation][:feeds]
    end

    def publish_pages
      if @config[:verbose_logging]
        Dimples.logger.debug_generation('pages', @pages.length)
      end

      @pages.each(&:write)
    end

    def publish_categories
      if @config[:verbose_logging]
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
          @config[:layouts][:category],
          options
        )
      end

      publish_category_feeds if @config[:generation][:category_feeds]
    end

    def publish_archives
      %w[year month day].each do |date_type|
        date_archives_sym = "#{date_type}_archives".to_sym
        next unless @config[:generation][date_archives_sym]

        @archives[date_type.to_sym].each do |date, posts|
          year, month, day = date.split('-')

          dates = { year: year }
          dates[:month] = month if month
          dates[:day] = day if day

          path = File.join(@output_paths[:archives], dates.values)

          layout = @config[:layouts][date_archives_sym]
          date_format = @config[:date_formats][date_type.to_sym]

          options = {
            context: { archive_date: posts[0].date, archive_type: date_type },
            title: posts[0].date.strftime(date_format)
          }

          paginate(self, posts, path, layout, options)
        end
      end
    end

    def publish_feeds(path, context)
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

    def publish_posts_feeds
      posts = @posts[0..@config[:pagination][:per_page] - 1]
      publish_feeds(@output_paths[:site], posts: posts)
    end

    def publish_category_feeds
      @categories.each_value do |category|
        path = File.join(@output_paths[:categories], category.slug)
        posts = category.posts[0..@config[:pagination][:per_page] - 1]

        publish_feeds(path, posts: posts, category: category.slug)
      end
    end

    def feed_templates
      @feed_templates ||= @templates.keys.select { |k| k =~ /^feeds\./ }
    end

    def copy_assets
      if Dir.exist?(@source_paths[:public])
        Dimples.logger.debug('Copying assets...') if @config[:verbose_logging]

        path = File.join(@source_paths[:public], '.')
        FileUtils.cp_r(path, @output_paths[:site])
      end
    rescue StandardError => e
      raise Errors::GenerationError, "Site assets failed to copy (#{e.message})"
    end

    def inspect
      "#<#{self.class} " \
      "@source_paths=#{@source_paths} " \
      "@output_paths=#{@output_paths}>"
    end

    private

    def post_class
      @post_class ||= if @config[:class_overrides][:post]
                        Object.const_get(config[:class_overrides][:post])
                      else
                        Dimples::Post
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
  end
end
