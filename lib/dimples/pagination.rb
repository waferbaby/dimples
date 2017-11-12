# frozen_string_literal: true

module Dimples
  # A module that supports pagination.
  module Pagination
    def paginate(site, items, path, layout, options = {})
      context = options.delete(:context) || {}
      url = path.sub(site.output_paths[:site], '') + '/'
      per_page = options.delete(:per_page) ||
                 site.config[:pagination][:per_page]

      pager = Pager.new(url, items, per_page, options)

      pager.each do |index, page_items|
        page = Dimples::Page.new(site)

        page.output_directory = if index == 1
                                  path
                                else
                                  File.join(path, "page#{index}")
                                end

        page.layout = layout
        page.title = options[:title] || site.templates[layout]&.title
        page.extension = options[:extension] if options[:extension]

        context[:items] = page_items
        context[:pagination] = pager.to_h

        page.write(context)
      end
    end

    # A class that models the context of a single page during pagination.
    class Pager
      include Enumerable

      attr_reader :current_page
      attr_reader :previous_page
      attr_reader :next_page
      attr_reader :page_count
      attr_reader :item_count

      def initialize(url, items, per_page, options = {})
        @url = url
        @items = items
        @per_page = per_page
        @page_count = (items.length.to_f / per_page.to_i).ceil
        @page_prefix = options[:page_prefix] || 'page'

        step_to(1)
      end

      def each(&block)
        (1..@page_count).each do |index|
          block.yield step_to(index), items_at(index)
        end
      end

      def step_to(page)
        @current_page = (1..@page_count).cover?(page) ? page : 1
        @previous_page = (@current_page - 1).positive? ? @current_page - 1 : nil
        @next_page = @current_page + 1 <= @page_count ? @current_page + 1 : nil

        @current_page
      end

      def items_at(page)
        @items.slice((page - 1) * @per_page, @per_page)
      end

      def current_page_url
        @current_page != 1 ? "#{@url}#{@page_prefix}#{@current_page}" : @url
      end

      def first_page_url
        @url
      end

      def last_page_url
        @page_count != 1 ? "#{@url}#{@page_prefix}#{@page_count}" : @url
      end

      def previous_page_url
        return unless @previous_page
        @previous_page != 1 ? "#{@url}#{@page_prefix}#{@previous_page}" : @url
      end

      def next_page_url
        "#{@url}#{@page_prefix}#{@next_page}" if @next_page
      end

      def to_h
        {
          url: @url,
          current_page: @current_page,
          page_count: @page_count,
          item_count: @items.count,
          previous_page: @previous_page,
          next_page: @next_page,
          links: {
            current_page: current_page_url,
            first_page: first_page_url,
            last_page: last_page_url,
            previous_page: previous_page_url,
            next_page: next_page_url
          }
        }
      end
    end
  end
end
