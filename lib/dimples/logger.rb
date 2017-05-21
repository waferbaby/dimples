module Dimples
  class Logger < Logger
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

  class LogFormatter < Logger::Formatter
    def self.call(severity, time, program_name, message)
      prefix = case severity
      when "ERROR"
        "\033[31mError:\033[0m "
      when 'DEBUG'
        "\033[93m- "
      end

      "#{prefix}#{message}\033[0m\n"
    end
  end
end
