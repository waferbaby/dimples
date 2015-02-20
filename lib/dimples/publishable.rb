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

      begin
        proc = Proc.new { |template| contents() }
        renderer = @path ? Tilt.new(@path, &proc) : Tilt::StringTemplate.new(&proc)
        output = renderer.render(nil, context) { body }.strip

        @rendered_contents = output
      rescue RuntimeError, TypeError, NoMethodError => e
        raise "Failed to render #{path ? path.gsub(@site.source_paths[:root], '') : type} - #{e}"
      end

      if use_layout && @layout && @site.templates[@layout]
        output = @site.templates[@layout].render(context, output)
      end

      output
    end
  end
end