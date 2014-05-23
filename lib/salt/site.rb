module Salt
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
    attr_accessor :markdown_engine

    def initialize(config = {})
      @source_paths = {}
      @output_paths = {}
      @templates = {}
      @categories = {}
      @archives = {}
      @hooks = {}

      @pages = []
      @posts = []

      @latest_post = false
      @klasses = { page: Salt::Page, post: Salt::Post }

      @config = Salt::Configuration.new(config)

      @source_paths[:root] = File.expand_path(@config['root'])

      %w{pages posts templates public}.each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      @output_paths[:site] = File.join(@source_paths[:root], @config['output']['site'])
      @output_paths[:posts] = File.join(@output_paths[:site], @config['output']['posts'])

      @markdown_engine = if @config['markdown']['enabled']
        Redcarpet::Markdown.new(Redcarpet::Render::HTML, @config['markdown']['options'])
      else
        false
      end
    end

    def register(klass)
      if klass.superclass == Salt::Page
        @klasses[:page] = klass
      elsif klass.superclass == Salt::Post
        @klasses[:post] = klass
      end
    end

    def set_hook(name, method)
      @hooks[name] = method
    end

    def call_hook(name, params)
      send(@hooks[name], params) if @hooks[name] && respond_to?(@hooks[name])
    end

    def scan_files
      Dir.glob(File.join(@source_paths[:templates], '*.*')).each do |path|
        template = Salt::Template.new(self, path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(self, path)
      end

      Dir.glob(File.join(@source_paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(self, path)
      end

      @posts.reverse!
      @latest_post = @posts.first

      @posts.each do |post|

        year = post.year.to_s
        month = post.month.to_s
        day = post.day.to_s

        @archives[year] ||= {posts: [], months: {}}

        @archives[year][:posts] << post
        @archives[year][:months][month] ||= {posts: [], days: {}}
        @archives[year][:months][month][:posts] << post
        @archives[year][:months][month][:days][day] ||= []
        @archives[year][:months][month][:days][day] << post

        post.categories.each do |category|
          (@categories[category] ||= []) << post
        end
      end
    end

    def generate
      begin
        scan_files
      rescue Exception => e
        raise "Failed to scan source files (#{e})"
      end

      begin
        Dir.mkdir(@output_paths[:site]) unless Dir.exist?(@output_paths[:site])
      rescue
        raise "Failed to create the site directory"
      end

      @posts.each do |post|
        begin
          call_hook(:before_post, post)
          post.write(@output_paths[:posts], {})
          call_hook(:after_post, post)
        rescue
          raise "Failed to generate post #{post}"
        end
      end

      @pages.each do |page|
        begin
          call_hook(:before_page, page)
          page.write(@output_paths[:site], {})
          call_hook(:after_page, page)
        rescue
          raise "Failed to generate page #{page}"
        end
      end

      if @config['pagination']['enabled']
        paginate(@posts, false, @config['pagination']['per_page'], [@output_paths[:site]], @config['layouts']['listing'])
      end

      if @config['generation']['year_archives']
        @archives.each do |year, archive|
          generate_year_archives(year, archive)
        end
      end

      if @config['generation']['categories']
        @categories.each_pair do |slug, posts|
          generate_category(slug, posts)
        end
      end

      if @config['generation']['feed']
        generate_feed(@output_paths[:site], {posts: @posts[0..@config['pagination']['per_page'] - 1]})
      end

      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '/.'), @output_paths[:site])
      rescue
        raise "Failed to copy site assets from #{@source_paths[:public]}"
      end
    end

    def generate_year_archives(year, params)
      if @config['generation']['month_archives']
        params[:months].each do |month, month_archive|
          generate_month_archives(year, month, month_archive)
        end
      end

      title = params[:posts][0].date.strftime(@config['date_formats']['year'])
      paginate(params[:posts], title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s], @config['layouts']['listing'])
    rescue
      raise "Failed to generate archives pages for #{year}"
    end

    def generate_month_archives(year, month, params)
      if @config['generation']['day_archives']
        params[:days].each do |day, posts|
          generate_day_archives(year, month, day, posts)
        end
      end

      title = params[:posts][0].date.strftime(@config['date_formats']['month'])
      paginate(params[:posts], title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s, month.to_s], @config['layouts']['listing'])
    rescue
      raise "Failed to generate archive pages for #{year}, #{month}"
    end

    def generate_day_archives(year, month, day, posts)
      title = posts[0].date.strftime(@config['date_formats'][:day])
      paginate(posts, title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s, month.to_s, day.to_s], @config['layouts']['listing'])
    rescue
      raise "Failed to generate archive pages for #{year}, #{month}, #{day}"
    end

    def generate_category(slug, posts)
      if @config['generation']['category_feeds']
        generate_feed(File.join(@output_paths[:posts], slug), {posts: posts[0..@config['pagination']['per_page'] - 1], category: slug})
      end

      paginate(posts, slug.capitalize, @config['pagination']['per_page'], [@output_paths[:posts], slug], @config['layouts']['category'])
    rescue
      raise "Failed to generate category pages for '#{slug}'"
    end

    def generate_feed(path, params)
      feed = @klasses[:page].new(self)

      feed.filename = 'feed'
      feed.extension = 'atom'
      feed.layout = 'feed'

      feed.write(path, params)
    rescue
      raise "Failed to build the feed at '#{path}'"
    end

    def paginate(posts, title, per_page, paths, layout, params = {})
      fail "'#{layout}' template not found" unless @templates[layout]

      pages = (posts.length.to_f / per_page.to_i).ceil

      for index in 0...pages
        range = posts.slice(index * per_page, per_page)

        page = @klasses[:page].new(self)

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

          if page_title
            page_title += " (Page #{index + 1})"
          else
            page_title = "Page #{index + 1}"
          end
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

        page.write(File.join(page_paths), {posts: range, pagination: pagination}.merge(params))
      end
    end

    def render_template(slug, body, context)
      @templates[slug] ? @templates[slug].render(self, body, context) : ''
    end
  end
end