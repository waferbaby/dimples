module Salt
  module Frontable
    def read_with_yaml(path)
      contents = File.read(path)
      matches = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)

      if matches
        metadata = YAML.load(matches[1])
        contents = matches.post_match.strip!

        metadata.each_pair do |key, value|
          set_metadata(key, value)
        end
      end

      contents
    end

    def set_metadata(key, value)
      unless instance_variable_get("@#{key}")
        self.class.send(:attr_accessor, key.to_sym)
        instance_variable_set("@#{key}", value)
      end
    end
  end
end