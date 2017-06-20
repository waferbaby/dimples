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
    'destination_path' => File.join('tmp', "dimples-#{Time.new.to_i}"),
    'categories' => [{ 'slug' => 'a', 'name' => 'A' }]
  )
end

def render_fixture(filename, locals = {})
  Tilt.new(File.join(__dir__, 'fixtures', filename)).render(nil, locals)
end
