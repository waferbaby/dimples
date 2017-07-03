# frozen_string_literal: true

module Dimples
  # A class that models a single site post.
  class Post < Page
    attr_accessor :categories
    attr_accessor :slug
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
    end

    def date=(date)
      @date = date

      @year = @date.strftime('%Y')
      @month = @date.strftime('%m')
      @day = @date.strftime('%d')
    end

    def output_path(parent_path)
      parent_path = @date.strftime(parent_path) if parent_path.match?(/%/)
      File.join([parent_path, @slug.to_s, "#{@filename}.#{@extension}"])
    end
  end
end
