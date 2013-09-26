module Salt
  class Template
    include Frontable

    attr_accessor :slug, :metadata, :contents, :parent

    def initialize(path)
      @slug = File.basename(path, File.extname(path))
      @contents = read_with_yaml(path)
    end

    def render(context, contents)
      site = Site.instance
      
      context['site'] ||= site

      output = Erubis::Eruby.new(@contents).evaluate(context) {
          contents
      }

      if responds_to?(@layout) && site.templates[@layout]
        output = site.templates[@layout].render(context, output)
      end

      output
    end
  end
end