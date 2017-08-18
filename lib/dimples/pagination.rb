# frozen_string_literal: true

module Dimples
  # A module that supports pagination.
  module Pagination
    def paginate(site:, items:, per_page:, path:, options: {})
      context = options[:context] || {}
      url = path.gsub(site.output_paths[:site], '') + '/'
      page_count = (items.length.to_f / per_page.to_i).ceil
      item_count = items.count

      (1..page_count).each do |index|
        page = Dimples::Page.new(site)

        page.title ||= options[:title]
        page.layout ||= options[:layout]
        page.extension ||= options[:extension]

        output_path = page.output_path(
          index != 1 ? File.join(path, "page#{index}") : path
        )

        pager = Pager.new(index, url, page_count, item_count)

        context[:items] = items.slice((index - 1) * per_page, per_page)
        context[:pagination] = pager.to_h

        page.write(output_path, context)
      end
    end

    # A class that models the context of a single page during pagination.
    class Pager
      attr_reader :previous_page, :next_page

      def initialize(page, url, page_count, item_count)
        @url = url
        @page_count = page_count
        @item_count = item_count

        step_to(page)
      end

      def step_to(page)
        return if page == @page

        @page = (1..@page_count).cover?(page) ? page : 1
        @previous_page = (@page - 1).positive? ? @page - 1 : nil
        @next_page = (@page + 1) <= @page_count ? @page + 1 : nil
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
          page: @page,
          page_count: @page_count,
          item_count: @item_count,
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
