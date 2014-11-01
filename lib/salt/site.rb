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

      @output_paths[:site] = File.join(@source_paths[:root], @config['paths']['site'])
      @output_paths[:posts] = File.join(@output_paths[:site], @config['paths']['posts'])

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
      Dir.glob(File.join(@source_paths[:templates], '**', '*.*')).each do |path|
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
        @archives[year][:months][month] ||= {posts: [], days: {}, name: post.date.strftime('%B')}
        @archives[year][:months][month][:posts] << post
        @archives[year][:months][month][:days][day] ||= []
        @archives[year][:months][month][:days][day] << post

        post.categories.each do |category|
          (@categories[category] ||= []) << post
        end
      end
    end

    def generate
      scan_files

      begin
        FileUtils.remove_dir(@output_paths[:site]) if Dir.exist?(@output_paths[:site])
        Dir.mkdir(@output_paths[:site])
      rescue => e
        raise "Failed to prepare the site directory (#{e})"
      end

      @posts.each do |post|
        begin
          call_hook(:before_post, post)
          post.write(@output_paths[:posts], {})
          call_hook(:after_post, post)
        rescue => e
          raise "Failed to render post #{File.basename(post.path)} (#{e})"
        end
      end

      @pages.each do |page|
        begin
          call_hook(:before_page, page)
          page.write(@output_paths[:site], {})
          call_hook(:after_page, page)
        rescue => e
          raise "Failed to render page from #{page.path.gsub(@source_paths[:root], '')} (#{e})"
        end
      end

      if @config['generation']['paginated_posts'] && @posts.length > 0
        begin
          paginate(@posts, false, @config['pagination']['per_page'], [@output_paths[:posts]], @config['layouts']['posts'])
        rescue => e
          raise "Failed to paginate main posts (#{e})"
        end
      end

      if @config['generation']['year_archives'] && @archives.length > 0
        begin
          generate_archives
        rescue => e
          raise "Failed to generate archives (#{e})"
        end
      end

      if @config['generation']['categories'] && @categories.length > 0
        @categories.each_pair do |slug, posts|  
          if @config['generation']['category_feeds']
            begin
              generate_feed(File.join(@output_paths[:posts], slug), {posts: posts[0..@config['pagination']['per_page'] - 1], category: slug})
            rescue => e
              raise "Failed to generate category feed for '#{slug}' (#{e})"
            end
          end

          begin
            paginate(posts, slug.capitalize, @config['pagination']['per_page'], [@output_paths[:posts], slug], @config['layouts']['category'])
          rescue => e
            raise "Failed to generate category pages for '#{slug}' (#{e})"
          end
        end
      end

      if @config['generation']['feed'] && @posts.length > 0
        begin
          generate_feed(@output_paths[:site], {posts: @posts[0..@config['pagination']['per_page'] - 1]})
        rescue => e
          raise "Failed to generate main feed (#{e})"
        end
      end

      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '.'), @output_paths[:site]) if Dir.exists?(@source_paths[:public])
      rescue => e
        raise "Failed to copy site assets (#{e})"
      end
    end

    def generate_archives
      if @config['layouts'].has_key?('year')
        year_template = @config['layouts']['year']
      elsif @config['layouts'].has_key?('archives')
        year_template = @config['layouts']['archives']
      else
        year_template = @config['layouts']['posts']
      end

      @archives.each do |year, year_archive|

        if @config['generation']['month_archives']
          if @config['layouts'].has_key?('month')
            month_template = @config['layouts']['month']
          elsif @config['layouts'].has_key?('archives')
            month_template = @config['layouts']['archives']
          else
            month_template = @config['layouts']['posts']
          end

          year_archive[:months].each do |month, month_archive|

            if @config['generation']['day_archives']

              if @config['layouts'].has_key?('day')
                day_template = @config['layouts']['day']
              elsif @config['layouts'].has_key?('archives')
                day_template = @config['layouts']['archives']
              else
                day_template = @config['layouts']['posts']
              end

              month_archive[:days].each do |day, posts|
                day_title = posts[0].date.strftime(@config['date_formats']['day'])
                paginate(posts, day_title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s, month.to_s, day.to_s], day_template)
              end
            end

            month_title = month_archive[:posts][0].date.strftime(@config['date_formats']['month'])
            paginate(month_archive[:posts], month_title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s, month.to_s], month_template)
          end
        end

        year_title = year_archive[:posts][0].date.strftime(@config['date_formats']['year'])
        paginate(year_archive[:posts], year_title, @config['pagination']['per_page'], [@output_paths[:posts], year.to_s], year_template)
      end
    end

    def generate_feed(path, params)
      feed = @klasses[:page].new(self)

      feed.filename = 'feed'
      feed.extension = 'atom'
      feed.layout = 'feed'

      feed.write(path, params)
    end

    def paginate(posts, title, per_page, paths, layout, params = {})
      fail "'#{layout}' template not found" unless @templates.has_key?(layout)

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

    def render(template_slug, content, layout = true)
      return '' unless @templates[template_slug]

      if content.is_a? String
        @templates[template_slug].render(self, content, {}, layout)
      elsif content.is_a? Hash
        @templates[template_slug].render(self, '', content, layout)
      else
        ''
      end
    end
  end
end