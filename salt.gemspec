$:.unshift File.expand_path('./lib')
 
require 'salt/version'
 
Gem::Specification.new do |s|
  s.name        = "salt"
  s.version     = Salt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Bogan"]
  s.email       = ["d+salt@waferbaby.com"]
  s.homepage    = "http://github.com/waferbaby/salt"
  s.summary     = "A very silly static site generator"
  s.description = "This is a very simple static site generator, born out of the loins of usesthis.com."
  s.license     = "LICENSE"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{bin,lib}/**/*")
  s.require_path = 'lib'
  s.executables << 'salt'
end