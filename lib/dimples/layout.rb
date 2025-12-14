# frozen_string_literal: true

module Dimples
  # A class for a single layout used on a site.
  class Layout < Entry
    def initialize(site:, path:)
      super(site: site, source: Pathname.new(path))
    end
  end
end
