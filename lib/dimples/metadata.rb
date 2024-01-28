# frozen_string_literal: true

require 'yaml'

module Dimples
  # A module implementing reading metadata from a file.
  module Metadata
    FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

    attr_accessor :path, :metadata, :contents

    def parse_file(path)
      @path = File.expand_path(path)
      @contents = File.read(path)

      matches = @contents.match(FRONT_MATTER_PATTERN)
      if matches.nil?
        metadata = {}
      else
        metadata = YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date])
        @contents = matches.post_match.strip
      end

      @metadata = default_metadata.merge(metadata)
    end

    private

    def default_metadata
      {
        filename: 'index.html',
        layout: nil
      }
    end

    def method_missing(method_name, *_args)
      @metadata[method_name] if @metadata.key?(method_name)
    end

    def respond_to_missing?(method_name, include_private)
      @metadata.key?(method_name) || super
    end
  end
end
