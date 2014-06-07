module Salt
  class Template
    include Frontable
    include Renderable

    attr_accessor :slug, :title, :path, :contents, :parent

    def initialize(site, path)
    	@site = site
      @slug = File.basename(path, File.extname(path))
      @path = path
      @contents = read_with_yaml(path)
    end
  end
end