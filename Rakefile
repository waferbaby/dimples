# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
  t.warning = true
end

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
