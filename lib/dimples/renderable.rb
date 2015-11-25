module Dimples
  module Renderable
    def render(context = {}, body = nil, use_layout = true)
      context[:site] = @site unless context[:site]
      context[:this] = self unless context[:this]

      scope = Object.new

      context.each_pair do |key, value|
        scope.instance_variable_set("@#{key}".to_sym, value)
      end

      begin
        output = renderer.render(scope) { body }.strip
        @rendered_contents = output
      rescue RuntimeError, TypeError, NoMethodError, SyntaxError, NameError => e
        problem_file = if @path
          @path.gsub(@site.source_paths[:root], '')
        else
          "dynamic #{self.class}"
        end

        raise Errors::RenderingError.new(problem_file, e.message)
      end

      if use_layout && defined?(@layout) && @site.templates[@layout]
        output = @site.templates[@layout].render(context, output)
      end

      output
    end

    def renderer
      proc = Proc.new { |template| contents() }

      if @path
        extension = File.extname(@path)[1..-1]
        options = @site.config['rendering'][extension] || {}

        Tilt.new(@path, options, &proc)
      else
        Tilt::StringTemplate.new(&proc)
      end
    end
  end
end