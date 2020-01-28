# frozen_string_literal: true

module Dimples
  # Default configuration options for a site.
  module Configuration
    def self.prepare(config)
      Hashie::Mash.new(defaults).deep_merge(config)
    end

    def self.defaults
      {
        source: Dir.pwd,
        destination: File.join(Dir.pwd, 'public'),
        paths: default_paths,
        generation: default_generation,
        layouts: default_layouts,
        pagination: default_pagination,
        date_formats: default_date_formats,
        feed_formats: default_feed_formats,
        category_names: {},
        rendering: {}
      }
    end

    def self.default_paths
      {
        archives: 'archives',
        paginated_posts: 'posts',
        posts: 'archives/%Y/%m/%d',
        drafts: 'archives/drafts/%Y/%m/%d',
        categories: 'archives/categories'
      }
    end

    def self.default_generation
      {
        paginated_posts: true,
        year_archives: true,
        month_archives: true,
        day_archives: true,
        categories: true,
        main_feed: true,
        category_feeds: true
      }
    end

    def self.default_layouts
      {
        post: 'post',
        category: 'category',
        paginated_post: 'paginated_post',
        archive: 'archive',
        date_archive: 'archive'
      }
    end

    def self.default_date_formats
      {
        year: '%Y',
        month: '%Y-%m',
        day: '%Y-%m-%d'
      }
    end

    def self.default_feed_formats
      ['atom']
    end

    def self.default_pagination
      {
        page_prefix: 'page_',
        per_page: 10
      }
    end
  end
end
