# frozen_string_literal: true

module Dimples
  class Post < Page
    POST_FILENAME = /(\d{4})-(\d{2})-(\d{2})-(.+)/

    def initialize(site, path)
      super

      parts = File.basename(path, File.extname(path)).match(POST_FILENAME)

      @metadata[:layout] ||= @site.config.layouts.post

      @metadata[:date] = Date.new(parts[1].to_i, parts[2].to_i, parts[3].to_i)
      @metadata[:slug] = parts[4]
      @metadata[:categories] ||= []
    end

    def year
      @year ||= @metadata[:date].strftime(@site.config.date_formats.year)
    end

    def month
      @month ||= @metadata[:date].strftime(@site.config.date_formats.month)
    end

    def day
      @day ||= @metadata[:date].strftime(@site.config.date_formats.day)
    end
  end
end
