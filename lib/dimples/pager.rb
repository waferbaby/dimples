# frozen_string_literal: true

module Dimples
  # A class that offers pagination.
  class Pager
    def initialize(site, items)
      @site = site
      @items = items
    end

    def paginate(per_page:, path:, layout:, context: {}, options: {})
      extension = options.delete(:extension)
      title     = options.delete(:title) || @site.templates[layout].title

      page_count = (@items.length.to_f / per_page.to_i).ceil
      item_count = @items.count

      (1..page_count).each do |index|
        page = @site.page_class.new(@site)

        page.layout = layout
        page.title = title
        page.extension = extension if extension

        output_path = page.output_path(
          index != 1 ? File.join(path, "page#{index}") : path
        )

        context[:items] = @items.slice((index - 1) * per_page, per_page)
        context[:pagination] = page_context(index, path, page_count, item_count)

        page.write(output_path, context)
      end
    end

    def page_context(page_index, path, page_count, item_count)
      context = {
        page: page_index,
        page_count: page_count,
        item_count: item_count,
        url: path.gsub(@site.output_paths[:site], '') + '/'
      }

      if (page_index - 1).positive?
        context[:previous_page] = page_index - 1
        context[:previous_page_url] = context[:url]

        if context[:previous_page] != 1
          context[:previous_page_url] += "page#{context[:previous_page]}"
        end
      end

      if (page_index + 1) <= page_count
        context[:next_page] = page_index + 1
        context[:next_page_url] = "#{context[:url]}page#{context[:next_page]}"
      end

      context
    end
  end
end
