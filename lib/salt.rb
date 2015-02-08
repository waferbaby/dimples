$LOAD_PATH.unshift(__dir__)

require 'rubygems'

require 'bundler/setup'
require 'fileutils'
require 'yaml'
require 'erubis'
require 'redcarpet'

require 'salt/frontable'
require 'salt/renderable'
require 'salt/configuration'
require 'salt/page'
require 'salt/post'
require 'salt/site'
require 'salt/template'