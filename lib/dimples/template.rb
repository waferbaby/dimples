module Dimples
  class Template
    include Frontable

    def initialize(site, path)
      @site = site
      @contents, @metadata = read_with_front_matter(path)
    end

    def render(page, context)
      payload = page.metadata.merge(context)

      puts "The payload for #{page} will be: #{payload}"
      # bubble up only if it itself has a template?
    end
  end
end