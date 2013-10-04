module Salt
  class Site
    attr_accessor :paths, :templates, :categories, :archives, :pages, :posts

    def self.instance
      @site ||= new
    end

    def initialize
      @paths = {}
      @templates = {}
      @categories = {}
      @archives = {}
      @pages = []
      @posts = []

      @klasses = {
        page: Salt::Page,
        post: Salt::Post,
      }
    end

    def setup(path = nil)
      @paths[:source] = path ? File.expand_path(path) : Dir.pwd

      %w{site pages posts templates public}.each do |path|
        @paths[path.to_sym] = File.join(@paths[:source], path)
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

    def paginate(posts, sub_paths = [])
      per_page = 10
      pages = (posts.length.to_f / per_page.to_i).ceil

      for index in 0...pages
        range = posts.slice(index * per_page, per_page)

        page = Page.new
        paths = [@paths[:site]]

        if sub_paths.length > 0
          paths.concat(sub_paths)
          url_path = "/#{sub_paths.join('/')}/"
        else
          url_path = '/'
        end

        paths.push("page#{index + 1}") if index > 0

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

        page.add_metadata(:layout, @klasses[:post].path)

        page.write(File.join(paths), {
          posts: range,
          pagination: pagination
        })
      end
    end

    def generate
      self.scan_files

      begin
        Dir.mkdir(@paths[:site]) unless Dir.exists?(@paths[:site])

        @pages.each do |page|
          page.write(@paths[:site])
        end

        @posts.each do |post|
          post.write(@paths[:site])
        end

        self.paginate(@posts)

        @archives.each do |year, data|
          data[:months].each do |month, posts|
            self.paginate(posts, [@klasses[:post].path, year.to_s, month.to_s])
          end

          self.paginate(data[:posts], [@klasses[:post].path, year.to_s])
        end

        @categories.each_pair do |slug, posts|
          self.paginate(posts, [@klasses[:post].path, slug])
        end

        FileUtils.cp_r(File.join(@paths[:public], '/.'), @paths[:site])
      rescue Exception => e
        puts e
      end
    end

    private
      attr_accessor :error, :klasses
  end
end