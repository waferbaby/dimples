# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'benchmark'
require 'fileutils'
require 'logger'
require 'tilt'
require 'yaml'

require 'dimples/errors'
require 'dimples/logger'

require 'dimples/frontable'

require 'dimples/category'
require 'dimples/configuration'
require 'dimples/page'
require 'dimples/pager'
require 'dimples/post'
require 'dimples/renderer'
require 'dimples/site'
require 'dimples/template'

# A static site generator.
module Dimples
  class << self
    def logger
      @logger ||= Dimples::Logger.new(STDOUT)
    end
  end
end
