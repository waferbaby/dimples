module Salt
  class Template
    include Frontable
    include Renderable

    attr_accessor :slug, :title, :path, :contents, :parent

    def initialize(site, path)
    	@site = site

      @slug = path.match(/#{@site.source_paths[:templates]}#{File::SEPARATOR}?(.+)\.erb/)[1]
      @path = path
      @contents = read_with_yaml(path)
    end
  end
end