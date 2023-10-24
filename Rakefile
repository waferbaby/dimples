# frozen_string_literal: true

desc 'Build the gem'
task :build do
  sh 'gem build dimples.gemspec'
end

desc 'Publish the gem to rubygems.org'
task :publish do
  require_relative 'lib/dimples/version'

  version = Dimples::VERSION
  filename = "dimples-#{version}.gem"

  sh "gem push #{filename}"
  sh "rm #{filename}"
end
