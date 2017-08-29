# frozen_string_literal: true

module Dimples
  # A mixin class that handles reading and parsing front matter from a file.
  module Frontable
    METADATA_KEYS = %w[title layout extension summary categories].freeze

    def read_with_front_matter
      @contents = File.read(@path)

      matches = @contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)
      return if matches.nil?

      metadata = YAML.safe_load(matches[1])

      metadata.each_pair do |key, value|
        if METADATA_KEYS.include?(key) && respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end

      @contents = matches.post_match.strip
    end
  end
end
