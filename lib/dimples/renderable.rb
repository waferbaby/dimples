# frozen_string_literal: true

module Dimples
  # A mixin class that allows a document to render via Tilt.
  module Renderable
    attr_accessor :rendered_contents

    def render(context = {}, body = nil)
      context[:site] ||= @site
      context[:this] ||= self
      context[:type] ||= self.class.name.split('::').last.downcase.to_sym

      scope = Object.new.tap do |s|
        context.each_pair do |key, value|
          s.instance_variable_set("@#{key}".to_sym, value)
        end
      end

      output = rendering_engine.render(scope) { body }.strip
      @rendered_contents = output

      if @site.templates[layout]
        @site.templates[layout].render(context, output)
      else
        output
      end
    end

    def rendering_engine
      @rendering_engine ||= begin
        callback = proc { contents }

        if @path
          ext = File.extname(@path)[1..-1]
          options = @site.config['rendering'][ext] || {}
          Tilt.new(@path, options, &callback)
        else
          Tilt::StringTemplate.new(&callback)
        end
      end
    end
  end
end
