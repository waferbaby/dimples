# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = Dir.glob('spec/**/*_spec.rb')
end

task default: :spec

task :build do
  Rake::Task['cleanup'].invoke
  puts `gem build dimples.gemspec`
end

task :publish do
  puts `gem push dimples*.gem`
  Rake::Task['cleanup'].invoke
end

task :cleanup do
  FileUtils.rm(Dir.glob('dimples*.gem'))
end
