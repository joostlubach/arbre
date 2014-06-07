# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "arbre/version"

Gem::Specification.new do |s|
  s.name        = "arbre2"
  s.version     = Arbre::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Greg Bell", "Joost Lubach"]
  s.email       = ["gregdbell@gmail.com", "joostlubach@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{An Object Oriented DOM Tree in Ruby}
  s.description = %q{An Object Oriented DOM Tree in Ruby}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "tzinfo"
  s.add_development_dependency "combustion", "~> 0.5"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "simplecov"
end
