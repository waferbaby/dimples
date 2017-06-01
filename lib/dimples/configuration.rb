# frozen_string_literal: true

module Dimples
  # A class that models a site's configuration.
  class Configuration
    def initialize(config = {})
      @settings = Dimples::Configuration.default_settings

      config.each_key do |key|
        if @settings[key].is_a?(Hash)
          @settings[key].merge!(config[key])
        else
          @settings[key] = config[key]
        end
      end
    end

    def [](key)
      @settings[key]
    end

    def class_override(type)
      klass = @settings['class_overrides'][type.to_s]
      Object.const_get(klass) unless klass.nil?
    end

    def self.default_settings
      {
        'source_path' => Dir.pwd,
        'destination_path' => File.join(Dir.pwd, 'site'),
        'verbose_logging' => false,
        'class_overrides' => { site: nil, post: nil, page: nil },
        'rendering' => {},
        'category_names' => {},
        'paths' => default_paths,
        'layouts' => default_layouts,
        'pagination' => default_pagination,
        'generation' => default_generation,
        'date_formats' => default_date_formats
      }
    end

    def self.default_layouts
      {
        'posts' => 'posts',
        'post' => 'post',
        'category' => 'category',
        'year_archives' => 'year_archives',
        'month_archives' => 'month_archives',
        'day_archives' => 'day_archives'
      }
    end

    def self.default_paths
      {
        'archives' => 'archives',
        'posts' => 'archives/%Y/%m/%d',
        'categories' => 'archives/categories'
      }
    end

    def self.default_pagination
      {
        'per_page' => 10
      }
    end

    def self.default_generation
      {
        'categories' => true,
        'year_archives' => true,
        'month_archives' => true,
        'day_archives' => true,
        'feeds' => true,
        'category_feeds' => true
      }
    end

    def self.default_date_formats
      {
        'year' => '%Y',
        'month' => '%Y-%m',
        'day' => '%Y-%m-%d'
      }
    end
  end
end
