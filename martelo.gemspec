# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "martelo/version"

Gem::Specification.new do |s|
  s.name        = "martelo"
  s.version     = Martelo::VERSION
  s.authors     = ["Aziz Shamim"]
  s.email       = ["azizshamim@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{a Gem for Nixland}
  s.description = %q{This gem delivers kickstart files based on templates and passed parameters}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "rack", '>= 1.3.2'
  s.add_dependency "sinatra", '>=1.2.6'
  s.add_dependency "json_pure", '>=1.5.4'
  s.add_dependency "haml", '>=3.1.2'
  s.add_dependency "redis", '2.2.2'
  s.add_development_dependency "rspec", '~> 2.6.0'
  s.add_development_dependency "rack-test", '>= 0.6.1'
  s.add_development_dependency "mime-types", '>= 1.16'
  s.add_development_dependency "rest-client", '>= 1.6.7'
end
