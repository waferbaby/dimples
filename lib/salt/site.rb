module Salt
  class Site
    include Singleton
    attr_accessor :paths, :settings, :templates, :categories, :archives, :pages, :posts

    def initialize
      @source_paths, @output_paths, @settings, @templates, @categories, @archives = {}, {}, {}, {}, {}, {}
      @pages, @posts = [], []

      @klasses = {
        page: Salt::Page,
        post: Salt::Post,
      }

      @settings = self.class.default_settings
    end

    def self.default_settings
      {
        use_markdown: true,
        markdown_options: {},
        posts_per_page: 10,
        pagination: true,
        categories: true,
        feed: true,
        category_feeds: true,
        output: {
          site: 'site',
          posts: 'archives',
        },
        archives: {
          years: '%Y',
          months: '%Y-%m',
          days: '%Y-%m-%d',
          layout: 'archives'
        }
      }
    end

    def setup(path = nil, config = {})
      @settings.each_key do |key|
        @settings[key] = config[key] if config.key?(key)
      end

      @source_paths[:root] = path ? File.expand_path(path) : Dir.pwd

      %w{pages posts templates public}.each do |path|
        @source_paths[path.to_sym] = File.join(@source_paths[:root], path)
      end

      @output_paths[:site] = File.join(@source_paths[:root], @settings[:output][:site])
      @output_paths[:posts] = File.join(@output_paths[:site], @settings[:output][:posts])
    end

    def register(klass)
      if klass.superclass == Salt::Page
        @klasses[:page] = klass
      elsif klass.superclass == Salt::Post
        @klasses[:post] = klass
      end
    end

    def path(key)
      @source_paths[key]
    end

    def scan_files
      Dir.glob(File.join(@source_paths[:templates], '*.*')).each do |path|
        template = Salt::Template.new(path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@source_paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(path)
      end

      Dir.glob(File.join(@source_paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(path)
      end

      @posts.reverse!

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
        self.scan_files
      rescue Exception => e
        raise "Failed to scan source files (#{e})"
      end

      begin
        Dir.mkdir(@output_paths[:site]) unless Dir.exists?(@output_paths[:site])
      rescue Exception => e
        raise "Failed to create the site directory (#{e})"
      end

      @pages.each do |page|
        begin
          page.write(self, @output_paths[:site])
        rescue Exception => e
          raise "Failed to generate page #{page} (#{e})"
        end
      end

      @posts.each do |post|
        begin
          post.write(self, @output_paths[:posts])
        rescue Exception => e
          raise "Failed to generate post #{post} (#{e})"
        end
      end

      self.paginate(@posts, false, [@output_paths[:site]]) if @settings[:pagination]

      if @settings[:archives][:years]
        @archives.each do |year, data|

          if @settings[:archives][:months]
            data[:months].each do |month, month_data|
              begin
                self.paginate(month_data[:posts], month_data[:posts][0].date.strftime(@settings[:archives][:months]), [@output_paths[:posts], year.to_s, month.to_s])
              rescue Exception => e
                raise "Failed to generate archive pages for #{year}, #{month} (#{e})"
              end

              if @settings[:archives][:days]
                month_data[:days].each do |day, posts|
                  begin
                    self.paginate(posts, posts[0].date.strftime(@settings[:archives][:days]), [@output_paths[:posts], year.to_s, month.to_s, day.to_s])
                  rescue Exception => e
                    raise "Failed to generate archive pages for #{year}, #{month}, #{day} (#{e})"
                  end
                end
              end
            end
          end

          begin
            self.paginate(data[:posts], data[:posts][0].date.strftime(@settings[:archives][:years]), [@output_paths[:posts], year.to_s])
          rescue Exception => e
            raise "Failed to generate archives pages for #{year} (#{e})"
          end
        end
      end

      if @settings[:categories]
        @categories.each_pair do |slug, posts|
          begin
            self.paginate(posts, slug.capitalize, [@output_paths[:posts], slug])

            if @settings[:category_feeds]
              feed = @klasses[:page].new

              feed.filename = 'feed'
              feed.extension = 'xml'

              feed.set_metadata(:layout, 'feed')

              begin
                feed.write(self, File.join(@output_paths[:posts], slug), {posts: posts, category: slug})
              rescue Exception => e
                raise "Failed to build the #{slug} feed (#{e})"
              end
            end

          rescue Exception => e
            raise "Failed to generate category pages for '#{slug}' (#{e})"
          end
        end
      end

      if @settings[:feed]
        feed = @klasses[:page].new

        feed.filename = 'feed'
        feed.extension = 'xml'

        feed.set_metadata(:layout, 'feed')

        begin
          feed.write(self, @output_paths[:site], {posts: @posts[0..@settings[:posts_per_page]]})
        rescue Exception => e
          raise "Failed to build the site feed (#{e})"
        end
      end

      begin
        FileUtils.cp_r(File.join(@source_paths[:public], '/.'), @output_paths[:site])
      rescue Exception => e
        raise "Failed to copy site assets from #{@source_paths[:public]} (#{e})"
      end
    end

    def paginate(posts, title, paths = [])
      pages = (posts.length.to_f / @settings[:posts_per_page].to_i).ceil
      template = @templates[@settings[:archives][:layout]]

      for index in 0...pages
        range = posts.slice(index * @settings[:posts_per_page], @settings[:posts_per_page])

        page = Page.new
        
        page_paths = paths.clone
        page_title = title || template.title

        url_path = "/#{File.split(page_paths[0])[-1]}/"
        url_path += "#{page_paths[1..-1].join('/')}/" if page_paths.length > 1

        if index > 0
          page_paths.push("page#{index + 1}")
          page_title += " (Page #{index + 1})"
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

        page.set_metadata(:layout, @settings[:archives][:layout])
        page.set_metadata(:title, page_title)

        page.write(self, File.join(page_paths), {
          posts: range,
          pagination: pagination
        })
      end
    end
  end
end