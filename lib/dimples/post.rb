# frozen_string_literal: true

require_relative "document"

require "date"

module Dimples
  class Post < Document
    def date
      @metadata.fetch(:date, DateTime.now)
    end

    def layout
      @metadata.fetch(:layout, "post")
    end

    def slug
      File.basename(@path, ".markdown")
    end
  end
end
