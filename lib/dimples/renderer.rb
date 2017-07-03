# frozen_string_literal: true

module Dimples
  # A class that renders the contents of a document into markup.
  class Renderer
    def initialize(site, source)
      @site = site
      @source = source

      callback = proc { @source.contents }

      @engine = if @source.path
                  Tilt.new(@source.path, {}, &callback)
                else
                  Tilt::StringTemplate.new(&callback)
                end
    end

    def render(context = {}, body = nil)
      output = @engine.render(scope(context)) { body }.strip
      @source.rendered_contents = output

      template = @site.templates[@source.layout]
      output = template.render(context, output) unless template.nil?

      output
    end

    def scope(context = {})
      context[:site] ||= @site
      context[:this] ||= @source
      context[:type] ||= @source.class.name.split('::').last.downcase.to_sym

      Object.new.tap do |scope|
        context.each_pair do |key, value|
          scope.instance_variable_set("@#{key}".to_sym, value)
        end
      end
    end
  end
end
