module Dimples
  class Metadata
    include Enumerable

    def initialize(source)
      source.each do |key, value|
        self.class.send(:attr_reader, key)
        instance_variable_set("@#{key}", build(value))
      end

      @data = source
    end

    def keys
      @data.keys
    end

    def [](key)
      @data[key]
    end

    def each_key(&block)
      @data.keys.each(&block)
    end

    def build(item)
      case item
      when Array
        item.map { |i| build(i) }
      when Hash
        item.empty? ? item : Metadata.new(item)
      else
        item
      end
    end
  end
end
