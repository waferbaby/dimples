require_relative 'document'

require 'date'

module Dimples
  class Post < Document
    def title
      @metadata.fetch(:title, 'Untitled')
    end

    def summary
      @metadata.fetch(:summary, '')
    end

    def categories
      @metadata.fetch(:categories, [])
    end

    def date
      @metadata.fetch(:date, DateTime.now)
    end

    def slug
      File.basename(@path, '.markdown')
    end
  end
end
