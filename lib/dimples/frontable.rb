# frozen_string_literal: true

module Dimples
  # Adds the ability to read frontmatter from a file.
  module Frontable
    FRONT_MATTER_PATTERN = /^(-{3}\n.*?\n?)^(-{3}*$\n?)/m.freeze

    def read_with_front_matter(path)
      contents = File.read(path)

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
