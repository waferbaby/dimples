require_relative 'document'

require 'date'

module Dimples
  class Post < Document
    def date
      @metadata.fetch(:date, DateTime.now)
    end
  end
end
