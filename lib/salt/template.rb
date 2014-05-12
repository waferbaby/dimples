module Salt
  class Template
    include Frontable
    include Renderable

    attr_accessor :slug, :title, :contents, :parent

    def initialize(site, path)
    	@site = site
      @slug = File.basename(path, File.extname(path))
      @contents = read_with_yaml(path)
    end
  end
end