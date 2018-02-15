# frozen_string_literal: true

module Dimples
  module Configuration
    def self.defaults
      {
        source_path: Dir.pwd,
        destination_path: File.join(Dir.pwd, 'site'),
        rendering: {},
        category_names: {},
        generation: default_generation,
        paths: default_paths,
        layouts: default_layouts,
        date_formats: default_date_formats,
        pagination: default_pagination
      }
    end

    def self.default_generation
      {
        paginated_posts: true,
        categories: true,

        post_feeds: true,
        category_feeds: true,
        archive_feeds: true,

        year_archives: true,
        month_archives: true,
        day_archives: true
      }
    end

    def self.default_paths
      {
        archives: 'archives',
        posts: 'archives/%Y/%m/%d',
        categories: 'archives/categories'
      }
    end

    def self.default_layouts
      {
        posts: 'posts',
        post: 'post',
        category: 'category',
        year_archives: 'year_archives',
        month_archives: 'month_archives',
        day_archives: 'day_archives'
      }
    end

    def self.default_date_formats
      {
        year: '%Y',
        month: '%Y-%m',
        day: '%Y-%m-%d'
      }
    end

    def self.default_pagination
      {
        per_page: 10
      }
    end
  end
end
