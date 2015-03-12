module Dimples
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

    def initialize(config = {})
      @source_paths = {}
      @output_paths = {}
      @templates = {}
      @categories = {}
      @archives = {year: {}, month: {}, day: {}}

      @pages = []
      @posts = []

      @latest_post = false

      @page_class = Dimples::Page
      @post_class = Dimples::Post

      @config = Dimples::Configuration.new(config)

      @source_paths[:root] = File.expand_path(@config['source_path'])
      @output_paths[:site] = File.expand_path(@config['destination_path'])

      %w{pages posts templates public}.each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      @output_paths[:posts] = File.join(@output_paths[:site], @config['paths']['posts'])
    end

    def generate
      prepare_site
      scan_files

      generate_posts
      generate_pages
      generate_archives

      generate_categories if @config['generation']['categories']
      generate_posts_feed if @config['generation']['feed']
      generate_category_feeds if @config['generation']['category_feeds']

      copy_assets
    end

    def prepare_site
      begin
        FileUtils.remove_dir(@output_paths[:site]) if Dir.exist?(@output_paths[:site])
        Dir.mkdir(@output_paths[:site])
      rescue => e
        raise "Failed to prepare the site directory (#{e})"
      end
    end

    def scan_files
      scan_templates
      scan_pages
      scan_posts
    end

    def scan_templates
      Dir.glob(File.join(@source_paths[:templates], '**', '*.*')).each do |path|
        template = Dimples::Template.new(self, path)
        @templates[template.slug] = template
      end
    end

    def scan_pages
      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        @pages << @page_class.new(self, path)
      end
    end

    def scan_posts

      Dir.glob(File.join(@source_paths[:posts], '*.*')).reverse.each do |path|
        post = @post_class.new(self, path)

        post.categories.each do |category|
          (@categories[category] ||= []) << post
        end

        %w[year month day].each do |date_type|
          if @config['generation']["#{date_type}_archives"]

            date_key = post.date.strftime(@config['date_formats'][date_type])
            (@archives[date_type.to_sym][date_key] ||= []) << post
          end
        end

        @posts << post
      end

      @latest_post = @posts.first
    end

    def generate_posts
      @posts.each do |post|
        begin
          post.write(@output_paths[:posts], {})
        rescue => e
          raise "Failed to render post #{post.path} (#{e})"
        end
      end

      if @config['generation']['paginated_posts']
        paginate(posts: @posts, paths: [@output_paths[:posts]], layout: @config['layouts']['posts'])
      end
    end

    def generate_pages
      @pages.each do |page|
        begin
          page.write(@output_paths[:site], {})
        rescue => e
          raise "Failed to render page #{page.path.gsub(@source_paths[:root], '')} (#{e})"
        end
      end
    end

    def generate_categories
      @categories.each_pair do |slug, posts|
        paginate(posts: posts, title: slug.capitalize, paths: [@output_paths[:posts], slug], layout: @config['layouts']['category'])
      end
    end

    def generate_archives
      %w[year month day].each do |date_type|

        if @config['generation']["#{date_type}_archives"]

          template = @config['layouts'][date_type] || @config['layouts']['archives'] || @config['layouts']['posts']
          archives[date_type.to_sym].each_pair do |date_title, posts|

            paths = [@output_paths[:posts], posts[0].year]
            paths << posts[0].month if date_type =~ /month|day/
            paths << posts[0].day if date_type == 'day'

            paginate(posts: posts, title: date_title, paths: paths, layout: template)
          end
        end
      end
    end

    def generate_feed(path, options)
      feed = @page_class.new(self)

      feed.filename = 'feed'
      feed.extension = 'atom'
      feed.layout = 'feed'

      begin
        feed.write(path, options)
      rescue => e
        raise "Failed to generate feed #{path} (#{e})"
      end
    end

    def generate_posts_feed
      generate_feed(@output_paths[:site], {posts: @posts[0..@config['pagination']['per_page'] - 1]})
    end

    def generate_category_feeds
      @categories.each_pair do |slug, posts|
        generate_feed(File.join(@output_paths[:posts], slug), {posts: posts[0..@config['pagination']['per_page'] - 1], category: slug})
      end
    end

    def copy_assets
      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '.'), @output_paths[:site]) if Dir.exists?(@source_paths[:public])
      rescue => e
        raise "Failed to copy site assets (#{e})"
      end
    end

    def pagination_url(page, paths)
      path = '/'

      path += File.split(paths[0])[-1] + "/" if paths[0] != @output_paths[:site]
      path += paths[1..-1].join('/') + "/" if paths.length > 1
      
      path
    end

    def paginate(posts:, title: nil, paths:, layout: false)
      fail "'#{layout}' template not found" unless @templates.has_key?(layout)

      per_page = @config['pagination']['per_page']
      page_count = (posts.length.to_f / per_page.to_i).ceil

      for index in 1..page_count
        range = posts.slice((index - 1) * per_page, per_page)

        page = @page_class.new(self)

        page.layout = layout
        page.title = title || @templates[layout].title

        page_paths = paths.clone

        pagination = {
          page: index,
          pages: page_count,
          post_count: posts.length,
          path: pagination_url(index, page_paths)
        }

        page_paths << "page#{index}" if index != 1

        pagination[:previous_page] = pagination[:page] - 1 if (pagination[:page] - 1) > 0
        pagination[:next_page] = pagination[:page] + 1 if (pagination[:page] + 1) <= pagination[:pages]

        path = File.join(page_paths)

        begin
          page.write(path, {posts: range, pagination: pagination})
        rescue => e
          raise "Failed to generate paginated page #{path} (#{e})"
        end
      end
    end
  end
end