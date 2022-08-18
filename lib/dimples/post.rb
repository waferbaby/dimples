require_relative 'document'

require 'date'

module Dimples
  class Post < Document
    def date
      @metadata.fetch(:date, DateTime.now)
    end

    def slug
      File.basename(@path, '.markdown')
    end
  end
end
