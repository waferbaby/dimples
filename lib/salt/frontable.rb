module Dimples
  module Frontable
    def read_with_yaml(path)
      if path =~ /.yml$/
        contents = ''
        metadata = YAML.load_file(path)
      else
        contents = File.read(path)
        matches = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)

        if matches
          metadata = YAML.load(matches[1])
          contents = matches.post_match.strip!
        end
      end

      if metadata
        metadata.each_pair do |key, value|
          unless instance_variable_get("@#{key}")
            self.class.send(:attr_accessor, key.to_sym)
            instance_variable_set("@#{key}", value)
          end
        end
      end

      contents
    end
  end
end