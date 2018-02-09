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

  s.executables << 'dimples'

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'

  s.add_dependency 'hashie', '~> 3.5.7'
  s.add_dependency 'tilt', '~> 2.0'
  s.add_dependency 'trollop', '~> 2.1'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.0'
  s.add_development_dependency 'erubis', '~> 2.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'redcarpet', '~> 3.3'
  s.add_development_dependency 'rspec', '~> 3.7.0'
  s.add_development_dependency 'simplecov', '~> 0.14'
  s.add_development_dependency 'timecop', '~> 0.9.1'
end
