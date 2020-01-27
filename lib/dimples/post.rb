# frozen_string_literal: true

module Dimples
  # A single dated post on a site.
  class Post < Page
    POST_FILENAME = /(\d{4})-(\d{2})-(\d{2})-(.+)/.freeze

    def initialize(site, path)
      super

      parts = File.basename(path, File.extname(path)).match(POST_FILENAME)

      @metadata[:layout] ||= @site.config.layouts.post

      @metadata[:date] = Date.new(parts[1].to_i, parts[2].to_i, parts[3].to_i)
      @metadata[:slug] = parts[4]
      @metadata[:categories] ||= []
      @metadata[:draft] ||= false
    end

    def year
      @year ||= @metadata[:date].strftime('%Y')
    end

    def month
      @month ||= @metadata[:date].strftime('%m')
    end

    def day
      @day ||= @metadata[:date].strftime('%d')
    end
  end
end
