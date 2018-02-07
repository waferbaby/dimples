module Dimples
  class Filter
    def self.process(action, item, &block)
      puts "I am before #{action} with #{item}"

      puts yield

      puts "I am after #{action} with #{item}"
    end
  end
end