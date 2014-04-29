module Salt
  module Renderable
    def render(site, body, context = {})
      context[:site] ||= site

      output = Erubis::Eruby.new(contents).evaluate(context) { body }
      output = site.templates[@layout].render(site, output, context) if @layout && site.templates[@layout]

      output
    rescue
      raise "Failed to render '#{body}'"
    end
  end
end