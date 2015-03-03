module Dimples
  module Publishable
    def write(path, context = {})
      output = render(context)

      publish_path = output_file_path(path)
      parent_path = File.dirname(publish_path)

      FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

      File.open(publish_path, 'w') do |file|
        file.write(output)
      end
    end

    def render(context = {}, body = nil, use_layout = true)
      context[:site] = @site unless context[:site]
      context[:this] = self unless context[:this]

      proc = Proc.new { |template| contents() }

      renderer = if @path
        extension = File.extname(@path)[1..-1]
        options = @site.config['rendering'][extension] || {}

        Tilt.new(@path, options, &proc)
      else
        Tilt::StringTemplate.new(&proc)
      end

      begin
        output = renderer.render(nil, context) { body }.strip
        @rendered_contents = output
      rescue RuntimeError, TypeError, NoMethodError, SyntaxError => e
        problem_file = if @path
          @path.gsub(@site.source_paths[:root], '')
        else
          "dynamic #{type}"
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