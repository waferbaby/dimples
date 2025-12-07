# frozen_string_literal: true

module Dimples
  module Entries
    # A class for a single layout used on a site.
    class Layout < Base
      def initialize(site:, path:)
        super(site: site, source: Pathname.new(path))
      end
    end
  end
end
