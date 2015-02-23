require 'fileutils'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.before(:all) do
    current_path = File.dirname(__dir__)

    @site = Dimples::Site.new({
      'source_path' => File.join(current_path, 'spec', 'fixtures'),
      'destination_path' => File.join(current_path, 'test_site')
    })
  end

  config.before(:example, publishing: true) do
    @site.scan_templates
    @site.scan_pages
    @site.scan_posts
  end

  config.after(:all) do
    begin
      FileUtils.remove_dir(@site.output_paths[:site])
    rescue
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
