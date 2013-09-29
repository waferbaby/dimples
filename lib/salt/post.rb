module Salt
  class Post < Page
    attr_accessor :slug, :date, :contents

    def initialize(site, path)
      super(site, path)
      
      parts = File.basename(path, File.extname(path)).match(/(\d{4})-(\d{2})-(\d{2})-(.+)/)

      @slug = parts[4]
      @date = Time.mktime(parts[1], parts[2], parts[3])

      @filename = 'index'
    end

    def output_path(parent_path)
      File.join(parent_path, 'posts', @slug)
    end
  end
end