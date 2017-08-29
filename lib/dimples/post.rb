# frozen_string_literal: true

module Dimples
  # A class that models a single site post.
  class Post < Page
    attr_accessor :slug
    attr_accessor :summary
    attr_accessor :categories
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day
    attr_accessor :previous_post
    attr_accessor :next_post
    attr_reader :date

    FILENAME_DATE = /(\d{4})-(\d{2})-(\d{2})-(.+)/

    def initialize(site, path)
      super(site, path)

      parts = File.basename(path, File.extname(path)).match(FILENAME_DATE)

      @filename = 'index'
      @slug = parts[4]
      @layout = @site.config['layouts']['post']

      self.date = Time.mktime(parts[1], parts[2], parts[3])

      @output_directory = File.join(
        @date.strftime(@site.output_paths[:posts]),
        @slug.to_s
      )
    end

    def date=(date)
      @date = date

      @year = @date.strftime('%Y')
      @month = @date.strftime('%m')
      @day = @date.strftime('%d')
    end

    def inspect
      "#<Dimples::Post @slug=#{@slug} @output_path=#{output_path}>"
    end
  end
end
