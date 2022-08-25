# frozen_string_literal: true

require 'yaml'

module Dimples
  module FrontMatter
    PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m.freeze

    def self.parse(contents)
      metadata = {}

      if (matches = contents.match(PATTERN))
        metadata = YAML.safe_load(matches[1], symbolize_names: true)
        contents = matches.post_match.strip
      end

      [metadata, contents]
    end
  end
end
