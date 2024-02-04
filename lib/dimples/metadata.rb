# frozen_string_literal: true

module Dimples
  # A class representing metadata passed into a template for rendering.
  class Metadata
    attr_reader :keys

    def initialize(source)
      source.each do |key, value|
        self.class.send(:attr_reader, key)
        instance_variable_set("@#{key}", build(value))
      end

      @keys = source.keys
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
