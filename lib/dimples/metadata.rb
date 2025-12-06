# frozen_string_literal: true

module Dimples
  # A class representing metadata passed into a template for rendering.
  class Metadata
    include Enumerable

    attr_reader :data

    def initialize(source = {})
      @data = {}

      source.each { |key, value| self[key] = value }
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = build(value)
    end

    def to_h
      @data
    end

    def each_key(&block)
      @data.keys.each(&block)
    end

    def method_missing(method_name, *_args)
      return @data[method_name] if @data.key?(method_name)

      nil
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name) || super
    end

    private

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
