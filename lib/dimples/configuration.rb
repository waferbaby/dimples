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
        pagination: default_pagination,
        date_formats: default_date_formats,
        feed_formats: default_feed_formats
      }
    end

    def self.default_generation
      {
        categories: true,

        main_feed: true,
        category_feeds: true,
        archive_feeds: true,

        archives: true,
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
        post: 'post',
        category: 'category',
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
        page_prefix: 'page',
        per_page: 10
      }
    end
  end
end
