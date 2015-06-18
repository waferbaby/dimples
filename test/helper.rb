require File.expand_path('lib/dimples')

require 'minitest'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

def test_site
  Dimples::Site.new({
    'source_path' => File.join(__dir__),
    'destination_path' => File.join(__dir__, 'test_site')
  })
end