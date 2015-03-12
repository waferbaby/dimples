module Dimples
  module Publishable
    def write(path, context = false)
      output = context ? render(context) : contents()

      publish_path = output_file_path(path)
      parent_path = File.dirname(publish_path)

      FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

      File.open(publish_path, 'w') do |file|
        file.write(output)
      end
    end

    def render(context = {}, body = nil, use_layout = true)
      class_name = self.class.name.split('::').last.downcase.to_sym

      context[:site] = @site unless context[:site]
      context[class_name] = self unless context[class_name]

      scope = Object.new

      context.each_pair do |key, value|
        scope.instance_variable_set("@#{key}".to_sym, value)
      end

      proc = Proc.new { |template| contents() }

      renderer = if @path
        extension = File.extname(@path)[1..-1]
        options = @site.config['rendering'][extension] || {}

        Tilt.new(@path, options, &proc)
      else
        Tilt::StringTemplate.new(&proc)
      end
    
      begin
        output = renderer.render(scope) { body }.strip
        @rendered_contents = output
      rescue RuntimeError, TypeError, NoMethodError, SyntaxError => e
        problem_file = if @path
          @path.gsub(@site.source_paths[:root], '')
        else
          "dynamic #{self.class}"
        end

        raise "Failed to render #{problem_file} - #{e}"
      end

      if use_layout && @layout && @site.templates[@layout]
        output = @site.templates[@layout].render(context, output)
      end

      output
    end
  end
end