module Salt
  class Template
    include Frontable
    include Publishable

    attr_accessor :slug
    attr_accessor :title
    attr_accessor :path
    attr_accessor :contents
    attr_accessor :parent

    def initialize(site, path)
    	@site = site
      @slug = File.basename(path, File.extname(path))
      @path = path

      @contents = read_with_yaml(path)
    end
  end
end