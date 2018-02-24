# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'dimples'

RSpec.configure do |config|
  config.before(:example) do
    @site_output = File.join(__dir__, 'tmp')
  end

  config.after(:example) do
    FileUtils.rm_rf(@site_output) if Dir.exist?(@site_output)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end