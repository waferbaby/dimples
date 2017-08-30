# frozen_string_literal: true

module Dimples
  # A mixin class that handles reading and parsing front matter from a file.
  module Frontable
    SKIPPED_METADATA_KEYS = %w[site path contents].freeze

    def read_with_front_matter
      @contents = File.read(@path)

      matches = @contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)
      return if matches.nil?

      YAML.safe_load(matches[1]).each_pair do |key, value|
        if !SKIPPED_METADATA_KEYS.include?(key) && respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end

      @contents = matches.post_match.strip
    end
  end
end
