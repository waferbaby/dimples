$LOAD_PATH.unshift(__dir__)

require 'fileutils'
require 'yaml'
require 'tilt'

require 'dimples/errors'

require 'dimples/frontable'
require 'dimples/writeable'
require 'dimples/renderable'

require 'dimples/configuration'
require 'dimples/category'
require 'dimples/page'
require 'dimples/post'
require 'dimples/site'
require 'dimples/template'