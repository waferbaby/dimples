module Salt
  class Configuration
    def initialize(config = {})
      @settings = Salt::Configuration.default_settings

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
      {
        'root' => Dir.pwd,

        'paths' => {
          'site' => 'site',
          'posts' => 'archives',
        },

        'layouts' => {
          'posts' => 'posts',
          'category' => 'category',
          'year' => 'year',
          'month' => 'month',
          'day' => 'day',
        },

        'markdown' => {
          'enabled' => true,
          'options' => {},
        },

        'pagination' => {
          'enabled' => true,
          'per_page' => 10,
        },

        'generation' => {
          'categories' => true,
          'year_archives' => true,
          'month_archives' => true,
          'day_archives' => true,
          'feed' => true,
          'category_feeds' => true,
        },

        'date_formats' => {
          'year' => '%Y',
          'month' => '%Y-%m',
          'day' => '%Y-%m-%d',
        }
      }
    end
  end
end