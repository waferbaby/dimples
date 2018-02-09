# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'hashie'
require 'tilt'
require 'yaml'

require 'dimples/frontable'
require 'dimples/renderable'

require 'dimples/configuration'
require 'dimples/errors'
require 'dimples/page'
require 'dimples/plugin'
require 'dimples/post'
require 'dimples/site'
require 'dimples/template'
