module Dimples
  class Configuration
    def initialize(config = {})
      @settings = Dimples::Configuration.default_settings

      if config
        @settings.each_key do |key|
          if config.key?(key)
            if @settings[key].is_a?(Hash)
              @settings[key].merge!(config[key])
            else
              @settings[key] = config[key]
            end
          end
        end
      end
    end

    def [](key)
      @settings[key]
    end

    def self.default_settings
      current_path = Dir.pwd

      {
        'source_path' => current_path,
        'destination_path' => File.join(current_path, 'site'),

        'paths' => {
          'archives' => 'archives',
          'posts' => 'archives/%Y/%m/%d',
          'categories' => 'archives/categories'
        },

        'layouts' => {
          'posts' => 'posts',
          'post' => 'post',
          'category' => 'category',
        },

        'rendering' => {
        },

        'pagination' => {
          'enabled' => true,
          'per_page' => 10,
        },

        'generation' => {
          'paginated_posts' => false,
          'categories' => true,
          'year_archives' => true,
          'month_archives' => true,
          'day_archives' => true,
          'feed' => true,
          'category_feeds' => true,
        },

        'file_extensions' => {
          'pages' => 'html',
          'posts' => 'html',
        },

        'date_formats' => {
          'year' => '%Y',
          'month' => '%Y-%m',
          'day' => '%Y-%m-%d',
        },

        'category_names' => {}
      }
    end
  end
end