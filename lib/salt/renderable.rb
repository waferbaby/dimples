module Salt
  module Renderable
    def render(site, body, context = {})
      context[:site] ||= site

      begin
        output = Erubis::Eruby.new(self.contents).evaluate(context) { body }
      rescue Exception => e
        raise "Failed to render '#{body}'"
      end

      output = site.templates[@layout].render(site, output, context) if @layout && site.templates[@layout]

      output
    end
  end
end