# frozen_string_literal: true

module Dimples
  # A collection of posts, organised by date.
  class Archive
    def initialize
      @years = {}
    end

    def add_post(post)
      year(post.year)[:posts] << post
      month(post.year, post.month)[:posts] << post
      day(post.year, post.month, post.day)[:posts] << post
    end

    def years
      @years.keys
    end

    def months(year)
      year(year)[:months].keys
    end

    def days(year, month)
      month(year, month)[:days].keys
    end

    def posts_for_date(year, month = nil, day = nil)
      if day
        day_posts(year, month, day)
      elsif month
        month_posts(year, month)
      else
        year_posts(year)
      end
    end

    def year_posts(year)
      year(year)[:posts]
    end

    def month_posts(year, month)
      month(year, month)[:posts]
    end

    def day_posts(year, month, day)
      day(year, month, day)[:posts]
    end

    private

    def year(year)
      @years[year.to_s] ||= { months: {}, posts: [] }
    end

    def month(year, month)
      year(year)[:months][month.to_s] ||= { days: {}, posts: [] }
    end

    def day(year, month, day)
      month(year, month)[:days][day.to_s] ||= { posts: [] }
    end
  end
end
