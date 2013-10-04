module Salt
  class Site
    attr_accessor :paths, :settings, :templates, :categories, :archives, :pages, :posts

    def self.instance
      @site ||= new
    end

    def initialize
      @paths, @templates, @categories, @archives = {}, {}, {}, {}
      @pages, @posts = [], []

      @klasses = {
        page: Salt::Page,
        post: Salt::Post,
      }

      @settings = {
        pagination: 10,
        archives: true,
        categories: true,
      }
    end

    def setup(path = nil, config = {})
      @paths[:source] = path ? File.expand_path(path) : Dir.pwd

      %w{site pages posts templates public}.each do |path|
        @paths[path.to_sym] = File.join(@paths[:source], path)
      end

      config[:classes].each do |klass|
        self.register(klass)
      end if config[:classes].kind_of?(Array)

      @settings.each_key do |key|
        @settings[key] = config[key] if config[key]
      end
    end

    def register(klass)
      if klass.superclass == Salt::Page
        @klasses[:page] = klass
      elsif klass.superclass == Salt::Post
        @klasses[:post] = klass
      end
    end

    def path(key)
      @paths[key]
    end

    def scan_files
      Dir.glob(File.join(@paths[:templates], '*.*')).each do |path|
        template = Salt::Template.new(path)
        @templates[template.slug] = template
      end

      Dir.glob(File.join(@paths[:pages], '**', '*.*')).each do |path|
        @pages << @klasses[:page].new(path)
      end

      Dir.glob(File.join(@paths[:posts], '*.*')).each do |path|
        @posts << @klasses[:post].new(path)
      end

      @posts.reverse!

      @posts.each do |post|

        year = post.date.year
        month = post.date.strftime('%m')
        
        @archives[year] ||= {posts: [], months: {}}
        @archives[year][:months][month] ||= []
        @archives[year][:posts] << post
        @archives[year][:months][month] << post

        post.categories.each do |category|
          (@categories[category] ||= []) << post
        end
      end
    end

    def paginate(posts, title, sub_paths = [])
      pages = (posts.length.to_f / @settings[:pagination].to_i).ceil

      for index in 0...pages
        range = posts.slice(index * @settings[:pagination], @settings[:pagination])

        page = Page.new
        paths = [@paths[:site]]

        if sub_paths.length > 0
          paths.concat(sub_paths)
          url_path = "/#{sub_paths.join('/')}/"
        else
          url_path = '/'
        end

        if index > 0
          paths.push("page#{index + 1}")
          title << " (Page #{index + 1})"
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

        page.set_metadata(:layout, @klasses[:post].path)
        page.set_metadata(:title, title)

        page.write(File.join(paths), {
          posts: range,
          pagination: pagination
        })
      end
    end

    def generate
      self.scan_files

      Dir.mkdir(@paths[:site]) unless Dir.exists?(@paths[:site])

      @pages.each do |page|
        page.write(@paths[:site])
      end

      @posts.each do |post|
        post.write(@paths[:site])
      end

      self.paginate(@posts, @klasses[:post].path.capitalize)

      if @settings[:archives]
        @archives.each do |year, data|
          data[:months].each do |month, posts|
            self.paginate(posts, posts[0].date.strftime('%B %Y'), [@klasses[:post].path, year.to_s, month.to_s])
          end

          self.paginate(data[:posts], year.to_s, [@klasses[:post].path, year.to_s])
        end
      end

      if @settings[:categories]
        @categories.each_pair do |slug, posts|
          self.paginate(posts, slug.capitalize, [@klasses[:post].path, slug])
        end
      end

      FileUtils.cp_r(File.join(@paths[:public], '/.'), @paths[:site])
    rescue Exception => e
      puts e
    end

    private
      attr_accessor :error, :klasses
  end
end