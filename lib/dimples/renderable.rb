module Dimples
  module Renderable
    def render(context = {}, body = nil, use_layout = true)
      begin
        output = renderer.render(build_scope(context)) { body }.strip
        @rendered_contents = output
      rescue RuntimeError, TypeError, NoMethodError, SyntaxError, NameError => e
        file = @path || "dynamic #{self.class}"
        raise Errors::RenderingError.new(file, e.message)
      end

      if use_layout && defined?(@layout) && @site.templates[@layout]
        output = @site.templates[@layout].render(context, output)
      end

      output
    end

    def build_scope(context)
      context[:site] ||= @site
      context[:this] ||= self
      context[:type] ||= self.class.name.split('::').last.downcase.to_sym

      scope = Object.new

      context.each_pair do |key, value|
        scope.instance_variable_set("@#{key}".to_sym, value)
      end

      scope
    end

    def renderer
      callback = proc { contents }

      if @path
        extension = File.extname(@path)[1..-1]
        options = @site.config['rendering'][extension] || {}

        Tilt.new(@path, options, &callback)
      else
        Tilt::StringTemplate.new(&callback)
      end
    end
  end
end
