module Salt
  class Template
    include Frontable

    attr_accessor :site, :slug, :metadata, :contents, :parent

    def initialize(site, path)
      @site = site
      @slug = File.basename(path, File.extname(path))
      @contents, @metadata = read_with_yaml(path)
    end

    def render(contents, context = {})
      
      context['site'] ||= @site

      output = Erubis::Eruby.new(@contents).evaluate(context) { contents }
      output = @site.render_template(@metadata['layout'], output, context) if @metadata['layout']

      output
    end
  end
end