# frozen_string_literal: true

module Dimples
  # A class for paginating a collection of posts.
  class Pager
    include Enumerable

    attr_reader :current_page, :previous_page, :next_page, :page_count

    def self.paginate(site:, url:, posts:, context: {}, &block)
      new(site: site, url: url, posts: posts).paginate(context: context, &block)
    end

    def initialize(site:, url:, posts:)
      @site = site
      @url = url
      @posts = posts

      @per_page = @site.config.pagination[:per_page]
      @page_prefix = @site.config.pagination[:page_prefix]
      @page_count = (posts.length.to_f / @per_page.to_i).ceil

      step_to(1)
    end

    def paginate(context: {})
      (1..@page_count).each do |index|
        step_to(index)

        output_directory = File.join(@site.config.build_paths[:root], current_page_url)

        context.merge!(pagination: metadata, url: current_page_url)

        @site.layouts[:posts]&.generate(
          output_path: File.join(output_directory, 'index.html'),
          context: context
        )

        yield(output_directory, context) if block_given?
      end
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

    def metadata
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
