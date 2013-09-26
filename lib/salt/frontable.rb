module Salt
  module Frontable
    def read_with_yaml(path)
      contents = File.read(path)
        
      if parts = contents.match(/^(-{3}\n.*?\n?)^(-{3}*$\n?)/m)
        metadata = YAML::load(parts[1])
        contents = parts.post_match.strip!

        metadata.each_pair do |key, value|
          instance_variable_set("@#{key}", value) unless respond_to?(key)
        end
      end

      contents
    end
  end
end