# frozen_string_literal: true

module Dimples
  # A simple Logger subclass.
  class Logger < ::Logger
    def initialize(*)
      super
      @formatter = LogFormatter
    end

    def debug_generation(type, count)
      message = "Generating #{type} (#{count} item"
      message += 's' if count != 1
      message += ')...'

      debug(message)
    end
  end

  # A simple Logger formatting subclass.
  class LogFormatter < Logger::Formatter
    def self.call(severity, _time, _program_name, message)
      case severity
      when 'ERROR'
        prefix = "\033[31mError:\033[0m "
      when 'DEBUG'
        prefix = "\033[93m- "
      end

      "#{prefix}#{message}\033[0m\n"
    end
  end
end
