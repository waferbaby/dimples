module Dimples
  class Post < Page
    FILENAME_DATE = /^(\d{4})-(\d{2})-(\d{2})/

    def initialize(site, path)
      super

      parts = File.basename(path, File.extname(path)).match(FILENAME_DATE)

      @metadata[:layout] = 'post'
      @metadata[:date] = Date.new(parts[1].to_i, parts[2].to_i, parts[3].to_i)

      @metadata[:year] = @metadata[:date].strftime('%Y')
      @metadata[:month] = @metadata[:date].strftime('%m')
      @metadata[:day] = @metadata[:date].strftime('%d')
    end
  end
end