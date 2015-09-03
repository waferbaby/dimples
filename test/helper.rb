require 'minitest/autorun'
require 'codeclimate-test-reporter'
require 'tilt/redcarpet'
require 'dimples'

CodeClimate::TestReporter.start

def test_site
  @site ||= Dimples::Site.new({
    'source_path' => File.join(__dir__, 'site'),
    'destination_path' => File.join(__dir__, 'build')
  })
end