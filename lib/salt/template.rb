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
      @slug = path.match(/#{@site.source_paths[:templates]}#{File::SEPARATOR}?(.+)\.erb/)[1]
      @path = path

      @contents = read_with_yaml(path)
    end
  end
end