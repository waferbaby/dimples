# frozen_string_literal: true

module Dimples
  module Sources
    # A class for a single layout used on a site.
    class Layout < Base
      def template
        @template ||= Tilt::ERBTemplate.new { @contents }
      end
    end
  end
end
