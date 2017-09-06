# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'dimples'
require 'tilt/redcarpet'
require 'tilt/erubis'
require 'little-fixtures'

def test_configuration
  {
    source_path: File.join(__dir__, 'source'),
    destination_path: File.join(
      File::SEPARATOR, 'tmp', "dimples-#{Time.new.to_i}"
    )
  }
end

def fixtures
  @fixtures ||= LittleFixtures.load(File.join(__dir__, 'fixtures'))
end

def clean_generated_site(site)
  files = File.join(site.output_paths[:site], '*')
  FileUtils.rm_r(Dir.glob(files), force: true)
end
