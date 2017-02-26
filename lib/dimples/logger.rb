module Dimples
  class LogFormatter < Logger::Formatter
    def self.call(severity, time, program_name, message)
      "#{time.strftime('%r')}: #{message}\n"
    end
  end
end