require 'minitest/autorun'
require 'codeclimate-test-reporter'
require 'dimples'

CodeClimate::TestReporter.start

def test_site
  Dimples::Site.new({
    'source_path' => File.join(__dir__, 'site'),
    'destination_path' => File.join(__dir__, 'build')
  })
end