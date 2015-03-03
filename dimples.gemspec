$:.unshift File.expand_path('./lib')
 
require 'dimples/version'
 
Gem::Specification.new do |s|
  s.name        = "dimples"
  s.version     = Dimples::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Bogan"]
  s.email       = ["d+dimples@waferbaby.com"]
  s.homepage    = "http://github.com/waferbaby/dimples"
  s.summary     = "A basic static site generator"
  s.description = "A very, very, very simple gem for building static websites."
  s.license     = "LICENSE"
 
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'

  s.add_dependency 'tilt', '~> 2.0'
end