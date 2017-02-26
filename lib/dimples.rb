$LOAD_PATH.unshift(__dir__)

require 'fileutils'
require 'yaml'
require 'tilt'
require 'logger'

require 'dimples/errors'
require 'dimples/logger'

require 'dimples/frontable'
require 'dimples/writeable'
require 'dimples/renderable'

require 'dimples/configuration'
require 'dimples/page'
require 'dimples/post'
require 'dimples/site'
require 'dimples/template'

module Dimples
  class << self
    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        logger.formatter = Dimples::LogFormatter
      end
    end
  end
end