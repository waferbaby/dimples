module Dimples
  module Writeable
    def write(path, context = {})
      output = context ? render(context) : contents()

      publish_path = output_file_path(path)
      parent_path = File.dirname(publish_path)

      begin
        FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

        File.open(publish_path, 'w+') do |file|
          file.write(output)
        end
      rescue SystemCallError => e
        raise Errors::PublishingError.new(publish_path, e.message)
      end
    end
  end
end