# frozen_string_literal: true

module Dimples
  # A mixin class that handles reading and parsing front matter from a file.
  module Frontable
    def read_with_front_matter(path)
      contents = File.read(path)
      matches = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)

      if matches
        metadata = YAML.safe_load(matches[1])
        contents = matches.post_match.strip

        apply_metadata(metadata) if metadata
      end

      contents
    end

    def apply_metadata(metadata)
      metadata.each_pair do |key, value|
        unless respond_to?(key.to_sym)
          self.class.send(:attr_accessor, key.to_sym)
        end

        send("#{key}=", value)
      end
    end
  end
end
