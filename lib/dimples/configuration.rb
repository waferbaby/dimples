# frozen_string_literal: true

module Dimples
  module Configuration
    def self.defaults
      {
        source_path: Dir.pwd,
        destination_path: File.join(Dir.pwd, 'site'),
        rendering: {},
        category_names: {},
        urls: default_urls,
        layouts: default_layouts,
        date_formats: default_date_formats
      }
    end

    def self.default_urls
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
  end
end
