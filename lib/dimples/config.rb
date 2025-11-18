# frozen_string_literal: true

module Dimples
  # Configuration settings for a site.
  class Config
    SOURCE_PATHS = { pages: 'pages', posts: 'posts', layouts: 'layouts', static: 'static' }.freeze

    attr_accessor :source_paths, :build_paths, :pagination, :generate_json

    def self.defaults
      {
        build: './site',
        source: Dir.pwd,
        pathnames: { posts: 'posts', categories: 'categories' },
        pagination: { page_prefix: 'page_', per_page: 5 },
        generate_json: false
      }
    end

    def initialize(options = {})
      options = Config.defaults.merge(options)

      @source_paths = expand_paths(File.expand_path(options[:source]), SOURCE_PATHS.dup)
      @build_paths = expand_paths(File.expand_path(options[:build]), options[:pathnames])
      @pagination = options[:pagination]
      @generate_json = options[:generate_json]
    end

    def expand_paths(root, paths)
      root = File.expand_path(root)

      paths.transform_values! { |value| File.expand_path(File.join(root, value)) }
      paths.tap { |expanded_paths| expanded_paths[:root] = root }
    end
  end
end
