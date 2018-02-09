# frozen_string_literal: true

module Dimples
  class Post < Page
    POST_FILENAME = /(\d{4})-(\d{2})-(\d{2})-(.+)/

    def initialize(site, path)
      super

      parts = File.basename(path, File.extname(path)).match(POST_FILENAME)

      @metadata[:layout] ||= @site.config.layouts.post

      @metadata[:date] = Date.new(parts[1].to_i, parts[2].to_i, parts[3].to_i)
      @metadata[:year] = @metadata[:date].strftime('%Y')
      @metadata[:month] = @metadata[:date].strftime('%m')
      @metadata[:day] = @metadata[:date].strftime('%d')

      @metadata[:slug] = parts[4]
    end

    private

    def output_directory
      @output_directory ||= File.join(
        @site.paths[:output],
        date.strftime(@site.config.urls.posts),
        slug
      )
    end
  end
end
