require File.expand_path('lib/dimples')

require 'minitest'
require 'tilt/redcarpet'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

def test_site
  Dimples::Site.new({
    'source_path' => File.join(__dir__, 'site'),
    'destination_path' => File.join(__dir__, 'build')
  })
end