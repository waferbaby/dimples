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
    'destination_path' => site_destination
  )
end

def site_destination
  File.join(File::SEPARATOR, 'tmp', "dimples-#{Time.new.to_i}")
end

def site_feed_template_types
  test_site.feed_templates.map do |template|
    template.split('.')[1]
  end
end

def read_fixture(filename)
  File.read(File.join(__dir__, 'fixtures', filename))
end

def compare_file_to_fixture(file_path, fixture_name)
  expected_output = read_fixture(fixture_name)
  File.read(file_path).must_equal(expected_output)
end

def clean_generated_site
  files = File.join(test_site.output_paths[:site], '*')
  FileUtils.rm_r(Dir.glob(files), force: true)
end

def archive_file_paths(date_type)
  test_site.archives[date_type].each_key.map do |date|
    dates = date.split('/')

    file_path = File.join(
      test_site.output_paths[:archives],
      dates,
      'index.html'
    )

    [dates.join('-'), file_path]
  end
end
