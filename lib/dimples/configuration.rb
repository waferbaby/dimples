# frozen_string_literal: true

module Dimples
  # Default configuration options for a site.
  module Configuration
    def self.defaults
      {
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
        output: 'site',
        archives: 'archives',
        posts: 'archives/%Y/%m/%d',
        categories: 'archives/categories'
      }
    end

    def self.default_generation
      {
        archives: true,
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
