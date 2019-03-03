# frozen_string_literal: true

module Dimples
  # Adds the ability to parse front matter from a file.
  class FrontMatter
    FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m.freeze

    def self.parse(contents)
      if (matches = contents.match(FRONT_MATTER_PATTERN))
        metadata = Hashie.symbolize_keys(YAML.safe_load(matches[1]))
        contents = matches.post_match.strip
      else
        metadata = {}
      end

      [contents, metadata]
    end
  end
end
