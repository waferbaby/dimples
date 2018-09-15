# frozen_string_literal: true

module Dimples
  # A single feed.
  class Feed < Page
    def initialize(site, format)
      super(site)

      self.filename = 'feed'
      self.extension = format
      self.layout = "feeds.#{format}"
    end
  end
end
