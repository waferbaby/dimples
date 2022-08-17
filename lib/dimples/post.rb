require 'date'
require 'redcarpet'
require 'yaml'

module Dimples
  class Post
    def date
      @metadata.fetch(:date, Date.now)
    end
  end
end
