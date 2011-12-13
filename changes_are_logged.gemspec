# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "changes_are_logged/version"

Gem::Specification.new do |s|
  s.name        = "changes_are_logged"
  s.version     = ChangesAreLogged::VERSION
  s.authors     = ["nyu", "jdb", "cef", "ejk"]
  s.email       = ""
  s.homepage    = ""
  s.summary     = %q{Log changes for record keeping}
  s.description = %q{change_log}

  s.rubyforge_project = "changes_are_logged"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here instead of Gemfile:
  s.add_development_dependency 'rspec-rails', '2.7.0'
  s.add_development_dependency 'activerecord', '3.0.11'
  s.add_development_dependency 'sqlite3', '1.3.4'
end
