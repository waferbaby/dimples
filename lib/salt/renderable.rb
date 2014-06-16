module Salt
  module Renderable
    def render(site, body, context = {}, layout = true)
      context[:site] ||= site

      begin
        output = Erubis::Eruby.new(contents).evaluate(context) { body }
      rescue SyntaxError => e
        raise "Syntax error in #{path.gsub(site.source_paths[:root], '')}"
      end

      output = site.templates[@layout].render(site, output, context) if @layout && site.templates[@layout] && layout

      output
    end
  end
end