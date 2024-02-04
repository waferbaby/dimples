# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'dimples/config'
require 'dimples/metadata'
require 'dimples/pager'
require 'dimples/site'

require 'dimples/sources/base'
require 'dimples/sources/page'
require 'dimples/sources/post'
require 'dimples/sources/layout'
