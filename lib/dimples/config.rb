# frozen_string_literal: true

module Dimples
  # Configuration settings for a site.
  class Config
    def self.defaults
      {
        sources: { root: '.', posts: './posts', pages: './pages', static: './static' },
        output: { root: './site', posts: './site/posts' }
      }
    end

    def initialize(options = {})
      @options = Config.defaults

      options.each do |key, value|
        @options[key].merge!(value)
      end

      %i[sources output].each do |type|
        @options[type].each { |key, value| @options[type][key] = File.expand_path(value) }
      end
    end

    def dig(*args)
      @options.dig(*args)
    end

    def [](key)
      @options[key]
    end
  end
end
