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
      "#{time.strftime('%r')}: #{'- ' if severity == 'DEBUG'}#{message}\n"
    end
  end
end