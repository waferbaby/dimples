# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("./lib")

require "dimples/version"

Gem::Specification.new do |s|
  s.name = "dimples"
  s.version = Dimples::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Daniel Bogan"]
  s.email = ["d+dimples@waferbaby.com"]
  s.homepage = "http://github.com/waferbaby/dimples"
  s.summary = "A basic static site generator"
  s.description = "A simple tool for building static websites."
  s.license = "MIT"

  s.required_ruby_version = "> 2.7"

  s.executables << "dimples"

  s.files = Dir["lib/**/*"]
  s.require_path = "lib"

  s.add_runtime_dependency "erubi", "~> 1.10"
  s.add_runtime_dependency "redcarpet", "~> 3.5"
  s.add_runtime_dependency "tilt", "~> 2.0"

  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "rubocop-rspec", "~> 2.22"
  s.add_development_dependency "standard", "~> 1.28"
end
