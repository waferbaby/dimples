# frozen_string_literal: true

module Dimples
  class Error < StandardError
  end

  class GenerationError < Error
  end

  class RenderingError < Error
  end
end
