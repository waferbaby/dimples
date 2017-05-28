# frozen_string_literal: true

module Dimples
  # A mixin class that neatly handles writing out a file.
  module Writeable
    def write(path, context = {})
      output = context ? render(context) : contents
      parent_path = File.dirname(path)

      FileUtils.mkdir_p(parent_path) unless Dir.exist?(parent_path)

      File.open(path, 'w+') do |file|
        file.write(output)
      end
    rescue SystemCallError => e
      error_message = "Failed to write #{path} (#{e.message})"
      raise Errors::PublishingError, error_message
    end
  end
end
