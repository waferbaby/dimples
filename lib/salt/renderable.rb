module Salt
  module Renderable
    def render(body, context = {})
      site = Site.instance
      context[:site] ||= site

      begin
        output = Erubis::Eruby.new(@contents).evaluate(context) { body }
      rescue Exception => e
        output = contents
      end

      output = site.templates[@layout].render(output, context) if @layout && site.templates[@layout]

      output
    end
  end
end