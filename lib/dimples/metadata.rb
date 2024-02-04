module Dimples
  class Metadata
    def initialize(source)
      source.each do |key, value|
        self.class.send(:attr_accessor, key)
        instance_variable_set("@#{key}", build(value))
      end
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

    def method_missing(_method_name, *_args)
      nil
    end

    def respond_to_missing?(_method_name, _include_private)
      true
    end
  end
end
