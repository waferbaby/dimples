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
      @generation_options = default_generation_options

      @source_paths[:root] = File.expand_path(@config['source_path'])
      @output_paths[:site] = File.expand_path(@config['destination_path'])

      %w{pages posts public templates}.each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      @output_paths[:archives] = File.join(@output_paths[:site], @config['paths']['archives'])
      @output_paths[:posts] = File.join(@output_paths[:site], @config['paths']['posts'])
      @output_paths[:categories] = File.join(@output_paths[:site], @config['paths']['categories'])
    end

    def generate(options = {})
      @generation_options.merge!(options)

      prepare_site
      scan_files
      generate_files
      copy_assets

    rescue Errors::RenderingError => e
      puts "Error: Failed to render #{e.file}: #{e.message}"
    rescue Errors::PublishingError => e
      puts "Error: Failed to publish #{e.file}: #{e.message}"
    rescue => e
      puts "Error: #{e}"
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
        prepare_template(template)
        @templates[template.slug] = template
      end
    end

    def scan_pages
      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        page = @page_class.new(self, path)
        prepare_page(page)
        @pages << page
      end
    end

    def scan_posts
      Dir.glob(File.join(@source_paths[:posts], '*.*')).reverse.each do |path|
        post = @post_class.new(self, path)
        next if !@generation_options[:include_drafts] && post.draft

        prepare_post(post)

        post.categories.each do |slug|
          (@categories[slug] ||= []) << post
        end

        %w[year month day].each do |date_type|
          if @config['generation']["#{date_type}_archives"]

            date_key = post.date.strftime(@config['date_formats'][date_type])
            (@archives[date_type.to_sym][date_key] ||= []) << post
          end
        end

        @posts << post
      end

      @posts.each_index do |index|
        @posts[index].next_post = @posts.fetch(index - 1, nil) if index - 1 >= 0
        @posts[index].previous_post = @posts.fetch(index + 1, nil) if index + 1 < @posts.count
      end

      @latest_post = @posts.first
    end

    def prepare_template(template)
    end

    def prepare_page(page)
    end

    def prepare_post(post)
    end

    def generate_files
      generate_posts
      generate_pages
      generate_archives

      generate_categories if @config['generation']['categories']
      generate_posts_feed if @config['generation']['feed']
      generate_category_feeds if @config['generation']['category_feeds']
    end

    def generate_posts
      @posts.each do |post|
        post.write(@output_paths[:posts])
      end

      if @config['generation']['paginated_posts']
        paginate(posts: @posts, paths: [@output_paths[:archives]], layout: @config['layouts']['posts'])
      end
    end

    def generate_pages
      @pages.each do |page|
        page.write(@output_paths[:site])
      end
    end

    def generate_categories
      @categories.each do |slug, posts|
        category_name = @config['category_names'][slug] || slug.capitalize
        paginate(posts: posts, title: category_name, paths: [@output_paths[:categories], slug], layout: @config['layouts']['category'], context: {category: slug})
      end
    end

    def generate_archives
      %w[year month day].each do |date_type|

        if @config['generation']["#{date_type}_archives"]

          template = @config['layouts'][date_type] || @config['layouts']['archives'] || @config['layouts']['posts']
          archives[date_type.to_sym].each_pair do |date_title, posts|

            paths = [@output_paths[:archives], posts[0].year]
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

      feed.write(path, options)
    end

    def generate_posts_feed
      generate_feed(@output_paths[:site], {posts: @posts[0..@config['pagination']['per_page'] - 1]})
    end

    def generate_category_feeds
      @categories.each do |slug, posts|
        generate_feed(File.join(@output_paths[:categories], slug), {posts: posts[0..@config['pagination']['per_page'] - 1], category: slug})
      end
    end

    def copy_assets
      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '.'), @output_paths[:site]) if Dir.exist?(@source_paths[:public])
      rescue => e
        raise "Failed to copy site assets (#{e})"
      end
    end

    def paginate(posts:, title: nil, paths:, layout: false, context: {})
      fail "'#{layout}' template not found" unless @templates.has_key?(layout)

      per_page = @config['pagination']['per_page']
      page_count = (posts.length.to_f / per_page.to_i).ceil

      pagination_path = paths[0].gsub(@output_paths[:site], '') + '/'
      pagination_path += paths[1..-1].join('/') + "/" if paths.length > 1

      for index in 1..page_count
        page = @page_class.new(self)

        page.layout = layout
        page.title = title || @templates[layout].title

        pagination = {
          page: index,
          pages: page_count,
          post_count: posts.length,
          path: pagination_path
        }

        pagination[:previous_page] = pagination[:page] - 1 if (pagination[:page] - 1) > 0
        pagination[:next_page] = pagination[:page] + 1 if (pagination[:page] + 1) <= pagination[:pages]

        if pagination[:previous_page]
          pagination[:previous_page_url] = pagination[:path]
          pagination[:previous_page_url] += "page" + pagination[:previous_page].to_s if pagination[:previous_page] != 1
        end

        pagination[:next_page_url] = pagination[:path] + "page" + pagination[:next_page].to_s if pagination[:next_page]

        output_path = File.join(paths, index != 1 ? "page#{index}" : '')
        context.merge!({posts: posts.slice((index - 1) * per_page, per_page), pagination: pagination})

        page.write(output_path, context)
      end
    end

    private

    def default_generation_options
      {
        include_drafts: false
      }
    end
  end
end