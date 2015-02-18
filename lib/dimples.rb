$LOAD_PATH.unshift(__dir__)

require 'rubygems'

require 'bundler/setup'
require 'fileutils'
require 'yaml'
require 'erubis'
require 'redcarpet'

require 'dimples/frontable'
require 'dimples/publishable'
require 'dimples/configuration'
require 'dimples/page'
require 'dimples/post'
require 'dimples/site'
require 'dimples/template'