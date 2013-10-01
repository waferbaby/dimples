module Salt
  module Frontable
    def read_with_yaml(path)
      contents = File.read(path)
        
      if parts = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)
        metadata = YAML::load(parts[1])
        contents = parts.post_match.strip!

        metadata.each_pair do |key, value|
          self.add_metadata(key, value)
        end
      end

      contents
    end

    def add_metadata(key, value)
      unless instance_variable_get("@#{key}")
        self.class.send(:attr_accessor, key.to_sym)
        instance_variable_set("@#{key}", value) 
      end
    end
  end
end