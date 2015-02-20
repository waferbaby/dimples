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
        renderer = Tilt.new(@path) { |template| contents() }
        output = renderer.render(nil, context) { body }.strip
      rescue RuntimeError, TypeError, NoMethodError => e
        raise "Failed to render #{type} #{path.gsub(@site.source_paths[:root], '')} - #{e}"
      end

      if use_layout && @layout && @site.templates[@layout]
        output = @site.templates[@layout].render(context, output)
      end

      output
    end
  end
end