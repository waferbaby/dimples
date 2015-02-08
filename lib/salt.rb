$LOAD_PATH.unshift(__dir__)

begin
  require 'rubygems'
  require 'bundler/setup'
  require 'fileutils'
  require 'yaml'
  require 'erubis'
  require 'redcarpet'
rescue LoadError => e
  puts "D'oh! Looks like you're missing the '#{e.path}' gem!"
  exit
end

require 'salt/frontable'
require 'salt/renderable'

require 'salt/configuration'
require 'salt/page'
require 'salt/post'
require 'salt/site'
require 'salt/template'