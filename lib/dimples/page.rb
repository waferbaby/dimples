# frozen_string_literal: true

module Dimples
  class Page
    include Frontable
    include Renderable

    attr_accessor :contents
    attr_accessor :metadata
    attr_accessor :path
    attr_writer :output_directory

    def initialize(site, path = nil)
      @site = site
      @path = path

      if @path
        @contents, @metadata = read_with_front_matter(@path)
      else
        @contents = ''
        @metadata = {}
      end

      @metadata[:title] ||= ''
    end

    def filename
      @metadata[:filename] || 'index'
    end

    def extension
      @metadata[:extension] || 'html'
    end

    def type
      :page
    end

    def write(output_directory, context = {})
      FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)
      output_path = File.join(output_directory, "#{filename}.#{extension}")

      File.write(output_path, render(context))
    rescue SystemCallError => e
      raise PublishingError, "Failed to publish file at #{output_path} (#{e})"
    end

    def inspect
      "#<#{self.class} @slug=#{slug} @output_directory=#{output_directory}>"
    end

    private

    def method_missing(method_name, *args, &block)
      if @metadata.key?(method_name)
        @metadata[method_name]
      elsif (matches = method_name.match(/([a-z]+)=/))
        @metadata[matches[1].to_sym] = args[0]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @metadata.key?(method_name) || method_name.match?(/([a-z]+)=/) || super
    end
  end
end
