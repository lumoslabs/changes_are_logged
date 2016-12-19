# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "changes_are_logged/version"

Gem::Specification.new do |s|
  s.name        = "changes_are_logged"
  s.version     = ChangesAreLogged::VERSION
  s.authors     = ['Lawrence Wang', 'Cameron Dutro']
  s.homepage    = 'https://github.com/lumoslabs/changes_are_logged'
  s.summary     = 'Tracks changes to your activerecord models'
  s.description = 'Tracks changes to your activerecord models'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', ENV.fetch('RAILS_VERSION', '>= 4.0')

  # specify any dependencies here instead of Gemfile:
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'sqlite3', '~> 1.3'
end
