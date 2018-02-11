# frozen_string_literal: true

module Dimples
  module Renderable
    def render(context = {}, body = nil)
      context[:site] ||= @site
      context[type] = Hashie::Mash.new(@metadata)

      output = engine.render(scope, context) { body }

      return output unless (template = @site.templates[@metadata[:layout]])
      template.render(context, output)
    end

    def scope
      @scope ||= Object.new.tap do |scope|
        scope.instance_variable_set(:@site, @site)

        scope.class.send(:define_method, :render) do |layout, locals = {}|
          @site.templates[layout]&.render(locals)
        end
      end
    end

    def engine
      @engine ||= begin
        callback = proc { @contents }

        if @path
          extension = File.extname(@path)
          options = @site.config.rendering[extension.to_sym] || {}

          Tilt.new(@path, options, &callback)
        else
          Tilt::StringTemplate.new(&callback)
        end
      end
    end
  end
end
