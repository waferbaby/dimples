# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./lib')

require 'dimples/version'

Gem::Specification.new do |s|
  s.name        = 'dimples'
  s.version     = Dimples::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Daniel Bogan']
  s.email       = ['d+dimples@waferbaby.com']
  s.homepage    = 'http://github.com/waferbaby/dimples'
  s.summary     = 'A basic static site generator'
  s.description = 'A simple tool for building static websites.'
  s.license     = 'MIT'

  s.required_ruby_version = '~> 2.7'

  s.executables << 'dimples'

  s.files        = Dir['lib/**/*']
  s.require_path = 'lib'

  s.add_runtime_dependency 'hashie', '~> 4.1'
  s.add_runtime_dependency 'optimist', '~> 3.0'
  s.add_runtime_dependency 'tilt', '~> 2.0'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  s.add_development_dependency 'erubis', '~> 2.7'
  s.add_development_dependency 'rake', '~> 12.3.3'
  s.add_development_dependency 'redcarpet', '~> 3.5'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'simplecov', '~> 0.21'
end
