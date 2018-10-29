# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'fileutils'
require 'hashie'
require 'tilt'
require 'yaml'

require 'dimples/frontable'

require 'dimples/archive'
require 'dimples/category'
require 'dimples/configuration'
require 'dimples/errors'
require 'dimples/pager'
require 'dimples/renderer'

require 'dimples/page'
require 'dimples/feed'
require 'dimples/post'
require 'dimples/template'

require 'dimples/site'
