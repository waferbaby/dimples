# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./lib')

require 'dimples/version'

Gem::Specification.new do |s|
  s.name = 'dimples'
  s.version = Dimples::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Daniel Bogan']
  s.email = ['d+dimples@waferbaby.com']
  s.homepage = 'http://github.com/waferbaby/dimples'
  s.summary = 'A basic static site generator'
  s.description = 'A simple tool for building static websites.'
  s.license = 'MIT'

  s.required_ruby_version = '> 3.0'

  s.executables << 'dimples'

  s.files = Dir['lib/**/*']
  s.require_path = 'lib'

  s.add_runtime_dependency 'erubi', '~> 1.12'
  s.add_runtime_dependency 'redcarpet', '~> 3.6'
  s.add_runtime_dependency 'tilt', '~> 2.3'

  s.metadata['rubygems_mfa_required'] = 'true'
end
