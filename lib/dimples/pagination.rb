# frozen_string_literal: true

module Dimples
  # A module that supports pagination.
  module Pagination
    def paginate(site:, items:, per_page:, path:, options: {})
      context = options[:context] || {}
      url = path.gsub(site.output_paths[:site], '') + '/'
      pager = Pager.new(url, items, per_page)

      pager.each do |index, page_items|
        page = Dimples::Page.new(site)

        page.title ||= options[:title]
        page.layout ||= options[:layout]
        page.extension ||= options[:extension]

        output_path = page.output_path(
          index != 1 ? File.join(path, "page#{index}") : path
        )

        context[:items] = page_items
        context[:pagination] = pager.to_h

        page.write(output_path, context)
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

      def initialize(url, items, per_page)
        @url = url
        @items = items
        @per_page = per_page
        @page_count = (items.length.to_f / per_page.to_i).ceil

        step_to(1)
      end

      def each(&block)
        (1..@page_count).each do |index|
          yield step_to(index), items_at(index)
        end
      end

      def step_to(page)
        @current_page = (1..@page_count).cover?(page) ? page : 1
        @previous_page = (@current_page - 1).positive? ? @current_page - 1 : nil
        @next_page = (@current_page + 1) <= @page_count ? @current_page + 1 : nil

        @current_page
      end

      def items_at(page)
        @items.slice((page - 1) * @per_page, @per_page)
      end

      def previous_page_url
        return unless @previous_page
        @previous_page != 1 ? "#{@url}page#{@previous_page}" : @url
      end

      def next_page_url
        "#{@url}page#{@next_page}" if @next_page
      end

      def to_h
        output = {
          page: @current_page,
          page_count: @page_count,
          item_count: @items.count,
          url: @url
        }

        if @previous_page
          output[:previous_page] = @previous_page
          output[:previous_page_url] = previous_page_url
        end

        if @next_page
          output[:next_page] = @next_page
          output[:next_page_url] = next_page_url
        end

        output
      end
    end
  end
end
