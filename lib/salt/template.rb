module Salt
  class Template
    include Frontable

    attr_accessor :slug, :contents, :parent

    def initialize(path)
      @slug = File.basename(path, File.extname(path))
      @contents = read_with_yaml(path)
    end

    def render(contents, context = {})
      site = Site.instance

      context[:site] ||= site

      output = Erubis::Eruby.new(@contents).evaluate(context) { contents }
      output = site.render_template(@layout, output, context) if @layout

      output
    end
  end
end