require 'codeclimate-test-reporter'
require 'minitest/autorun'
require 'tilt/redcarpet'
require 'tilt/erubis'
require 'dimples'

CodeClimate::TestReporter.start

def test_site
  @site ||= Dimples::Site.new({
    'source_path' => File.join(__dir__, 'site'),
    'destination_path' => File.join(__dir__, 'build')
  })
end