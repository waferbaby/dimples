# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'tilt/redcarpet'
require 'tilt/erubis'
require 'dimples'

def test_site
  @site ||= Dimples::Site.new(test_configuration)
end

def test_configuration
  @config ||= Dimples::Configuration.new(
    'source_path' => File.join(__dir__, 'source'),
    'destination_path' => site_destination,
    'category_names' => { 'green' => 'G R E E N' }
  )
end

def site_destination
  File.join(File::SEPARATOR, 'tmp', "dimples-#{Time.new.to_i}")
end

def read_fixture(filename)
  File.read(File.join(__dir__, 'fixtures', "#{filename}.html"))
end

def match_expected_output(fixture_name, test_file_path)
  expected_output = read_fixture(fixture_name)
  File.read(test_file_path).must_equal(expected_output)
end
