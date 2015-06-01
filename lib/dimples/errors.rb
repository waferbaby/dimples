module Dimples
  module Errors
    class Error < RuntimeError
      attr_reader :file

      def initialize(file, message)
        @file = file
        super(message)
      end
    end

    class PublishingError < Error
    end

    class RenderingError < Error
    end
  end
end