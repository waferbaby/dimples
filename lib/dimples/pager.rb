# frozen_string_literal: true

module Dimples
  # A class for paginating a collection of posts.
  class Pager
    PER_PAGE = 5

    include Enumerable

    attr_reader :current_page, :previous_page, :next_page, :page_count

    def self.paginate(url, posts, config, ...)
      new(url, posts, config).each(...)
    end

    def initialize(url, posts, config)
      @url = url
      @posts = posts
      @per_page = config.dig(:pagination, :per_page) || PER_PAGE
      @page_prefix = config.dig(:pagination, :page_prefix) || 'page_'
      @page_count = (posts.length.to_f / @per_page.to_i).ceil

      step_to(1)
    end

    def each
      (1..@page_count).each { |index| yield(step_to(index), to_context) if block_given? }
    end

    def step_to(page)
      @current_page = page
      @previous_page = previous_page? ? @current_page - 1 : nil
      @next_page = next_page? ? @current_page + 1 : nil

      @current_page
    end

    def posts_at(page)
      @posts.slice((page - 1) * @per_page, @per_page)
    end

    def previous_page?
      (@current_page - 1).positive?
    end

    def next_page?
      @current_page + 1 <= @page_count
    end

    def current_page_url
      @current_page == 1 ? @url : "#{@url}#{@page_prefix}#{@current_page}"
    end

    def first_page_url
      @url
    end

    def last_page_url
      @page_count == 1 ? @url : "#{@url}#{@page_prefix}#{@page_count}"
    end

    def previous_page_url
      return unless @previous_page

      @previous_page == 1 ? @url : "#{@url}#{@page_prefix}#{@previous_page}"
    end

    def next_page_url
      "#{@url}#{@page_prefix}#{@next_page}" if @next_page
    end

    def urls
      {
        current_page: current_page_url,
        first_page: first_page_url,
        last_page: last_page_url,
        previous_page: previous_page_url,
        next_page: next_page_url
      }
    end

    def to_context
      {
        posts: posts_at(current_page),
        current_page: @current_page,
        page_count: @page_count,
        post_count: @posts.count,
        previous_page: @previous_page,
        next_page: @next_page,
        urls: urls
      }
    end
  end
end
