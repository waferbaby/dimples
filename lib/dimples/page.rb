module Dimples
  class Page
    include Frontable

    attr_accessor :contents
    attr_accessor :metadata
    attr_accessor :path

    def initialize(site, path = nil)
      @site = site
      @path = path

      if @path
        @contents, @metadata = read_with_front_matter(@path)
      else
        @contents = ''
        @metadata = {}
      end
    end

    def output_directory
      @output_path ||= if @path
        File.dirname(@path).sub(
          @site.paths[:pages],
          @site.paths[:output]
        )
      else
        @site.paths[:output]
      end
    end

    def filename
      @metadata[:filename] || 'index'
    end

    def extension
      @metadata[:extension] || 'html'
    end

    def template
      @template ||= @metadata[:layout] ? @site.templates[@metadata[:layout]] : nil
    end

    def render(context = {})
      return @contents unless template
      template.render(self, context)
    end

    def write(context = {})
      output = render(context)
      path = File.join(output_directory, "#{filename}.#{extension}")

      puts "Writing to #{path}"
    end

    def method_missing(name, *args, &block)
      @metadata.has_key?(name.to_s) ? @metadata[name] : super
    end
  end
end