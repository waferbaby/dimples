# frozen_string_literal: true

module Dimples
  class Renderer
    def initialize(site, source)
      @site = site
      @source = source
    end

    def render(context = {}, body = nil)
      context[:site] ||= @site
      context[:pagination] ||= nil

      output = engine.render(scope, context) { body }

      template = @site.templates[@source.metadata[:layout]]
      return output if template.nil?

      template.render(context, output)
    end

    def engine
      @engine ||= begin
        callback = proc { @source.contents }

        if @source.path
          extension = File.extname(@source.path)
          options = @site.config.rendering[extension.to_sym] || {}

          Tilt.new(@source.path, options, &callback)
        else
          Tilt::StringTemplate.new(&callback)
        end
      end
    end

    def scope
      @scope ||= Object.new.tap do |scope|
        scope.instance_variable_set(:@site, @site)

        scope.class.send(:define_method, :render) do |layout, locals = {}|
          @site.templates[layout]&.render(locals)
        end
      end
    end
  end
end
