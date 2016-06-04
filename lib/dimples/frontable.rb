module Dimples
  module Frontable
    def read_with_yaml(path)
      if File.extname(path) == '.yml'
        contents = ''
        metadata = YAML.load_file(path)
      else
        contents = File.read(path)
        matches = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)

        if matches
          metadata = YAML.load(matches[1])
          contents = matches.post_match.strip
        end
      end

      apply_metadata(metadata) if metadata

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
