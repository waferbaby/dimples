module Salt
  module Renderable
    def render(site, body, context = {})
      context[:site] ||= site

      begin
        output = Erubis::Eruby.new(@contents).evaluate(context) { body }
      rescue Exception => e
        output = contents
      end

      output = site.templates[@layout].render(site, output, context) if @layout && site.templates[@layout]

      output
    end
  end
end