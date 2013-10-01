module Salt
  class Template
    include Frontable

    attr_accessor :slug, :contents, :parent

    def initialize(path)
      @slug = File.basename(path, File.extname(path))
      @contents = read_with_yaml(path)
    end

    def render(contents, context = Object.new)
      site = Site.instance

      output = Erubis::Eruby.new(@contents).evaluate({ site: site, this: context }) { contents }
      output = site.render_template(@layout, output, context) if @layout

      output
    end
  end
end