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
      @archives = {}

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

    def scan_files
      Dir.glob(File.join(@source_paths[:templates], '**', '*.*')).each do |path|
        template = Dimples::Template.new(self, path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        @pages << @page_class.new(self, path)
      end

      Dir.glob(File.join(@source_paths[:posts], '*.*')).each do |path|
        @posts << @post_class.new(self, path)
      end

      @posts.reverse!
      @latest_post = @posts.first
    end

    def generate
      scan_files
      
      begin
        FileUtils.remove_dir(@output_paths[:site]) if Dir.exist?(@output_paths[:site])
        Dir.mkdir(@output_paths[:site])
      rescue => e
        raise "Failed to prepare the site directory (#{e})"
      end

      generate_posts
      generate_pages

      if @config['generation']['paginated_posts'] && @posts.length > 0
        paginate(@posts, false, @config['pagination']['per_page'], [@output_paths[:posts]], @config['layouts']['posts'])
      end

      if @config['generation']['year_archives']
        generate_archives
      end

      if @config['generation']['categories'] && @categories.length > 0
        generate_categories
      end

      if @config['generation']['feed'] && @posts.length > 0
        generate_feed(@output_paths[:site], {posts: @posts[0..@config['pagination']['per_page'] - 1]})
      end

      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '.'), @output_paths[:site]) if Dir.exists?(@source_paths[:public])
      rescue => e
        raise "Failed to copy site assets (#{e})"
      end
    end

    def generate_posts
      @posts.each do |post|
        begin
          post.write(@output_paths[:posts])
        rescue => e
          raise "Failed to render post #{post.path} (#{e})"
        end
      end
    end

    def generate_pages
      @pages.each do |page|
        begin
          page.write(@output_paths[:site])
        rescue => e
          raise "Failed to render page #{page.path.gsub(@source_paths[:root], '')} (#{e})"
        end
      end
    end

    def generate_categories
      @categories.each_pair do |slug, posts|
        if @config['generation']['category_feeds']
          generate_feed(File.join(@output_paths[:posts], slug), {posts: posts[0..@config['pagination']['per_page'] - 1], category: slug})
        end

        paginate(posts, slug.capitalize, @config['pagination']['per_page'], [@output_paths[:posts], slug], @config['layouts']['category'])
      end
    end

    def generate_archives
      archives = {year: {}, month: {}, day: {}}

      @posts.each do |post|
        %w[year month day].each do |date_type|

          if @config['generation']["#{date_type}_archives"]

            date_key = post.date.strftime(@config['date_formats'][date_type])
            (archives[date_type.to_sym][date_key] ||= []) << post
          end
        end
      end

      %w[year month day].each do |date_type|

        if @config['generation']["#{date_type}_archives"]

          template = @config['layouts'][date_type] || @config['layouts']['archives'] || @config['layouts']['posts']
          archives[date_type.to_sym].each_pair do |date_title, posts|

            paths = [@output_paths[:posts], posts[0].year]
            paths << posts[0].month if date_type =~ /month|day/
            paths << posts[0].day if date_type == 'day'

            paginate(posts, date_title, @config['pagination']['per_page'], paths, template)
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

    def paginate(posts, title, per_page, paths, layout, params = {})
      fail "'#{layout}' template not found" unless @templates.has_key?(layout)

      pages = (posts.length.to_f / per_page.to_i).ceil

      for index in 0...pages
        range = posts.slice(index * per_page, per_page)

        page = @page_class.new(self)

        page_paths = paths.clone
        page_title = title ? title : @templates[layout].title

        if page_paths[0] == @output_paths[:site]
          url_path = '/'
        else
          url_path = "/#{File.split(page_paths[0])[-1]}/"
        end

        url_path += "#{page_paths[1..-1].join('/')}/" if page_paths.length > 1

        if index > 0
          page_paths.push("page#{index + 1}")
        end

        pagination = {
          page: index + 1,
          pages: pages,
          total: posts.length,
          path: url_path
        }

        if (pagination[:page] - 1) > 0
          pagination[:previous_page] = pagination[:page] - 1
        end

        if (pagination[:page] + 1) <= pagination[:pages]
          pagination[:next_page] = pagination[:page] + 1
        end

        page.layout = layout
        page.title = page_title

        path = File.join(page_paths)

        begin
          page.write(path, {posts: range, pagination: pagination}.merge(params))
        rescue => e
          raise "Failed to generate paginated page #{path} (#{e})"
        end
      end
    end
  end
end