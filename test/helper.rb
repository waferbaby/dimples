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
    'categories' => [{ 'slug' => 'a', 'name' => 'A' }]
  )
end

def site_destination
  File.join(File::SEPARATOR, 'tmp', "dimples-#{Time.new.to_i}")
end

def render_template(filename, locals = {})
  Tilt.new(File.join(__dir__, 'templates', "#{filename}.erb")).render(nil, locals)
end
