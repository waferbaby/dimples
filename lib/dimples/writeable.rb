module Dimples
  module Writeable
    def write(path, context = {})
      output = context ? render(context) : contents
      parent_path = File.dirname(path)

      FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

      File.open(path, 'w+') do |file|
        file.write(output)
      end
    rescue SystemCallError => e
      raise Errors::PublishingError.new("Failed to write #{path} (#{e.message})")
    end
  end
end
