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
    'destination_path' => File.join(
      File::SEPARATOR, 'tmp', "dimples-#{Time.new.to_i}"
    )
  )
end

def fixtures
  @fixtures ||= LittleFixtures.load(File.join(__dir__, 'fixtures'))
end

def clean_generated_site
  files = File.join(test_site.output_paths[:site], '*')
  FileUtils.rm_r(Dir.glob(files), force: true)
end