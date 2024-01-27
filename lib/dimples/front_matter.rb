# frozen_string_literal: true

require 'yaml'

module Dimples
  module FrontMatter
    PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m

    def self.parse(contents)
      matches = contents.match(PATTERN)
      return [{}, contents] if matches.nil?

      metadata = YAML.safe_load(matches[1], symbolize_names: true, permitted_classes: [Date])
      contents = matches.post_match.strip

      [metadata, contents]
    end
  end
end
