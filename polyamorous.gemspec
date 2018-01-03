# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "polyamorous/version"

Gem::Specification.new do |s|
  s.name        = "polyamorous"
  s.version     = Polyamorous::VERSION
  s.authors     = ["Ernie Miller", "Ryan Bigg", "Jon Atack", "Xiang Li"]
  s.email       = ["ernie@erniemiller.org", "radarlistener@gmail.com", "jonnyatack@gmail.com", "bigxiang@gmail.com"]
  s.homepage    = "https://github.com/activerecord-hackery/polyamorous"
  s.license     = "MIT"
  s.summary     = %q{
    Loves/is loved by polymorphic belongs_to associations, Ransack, Squeel, MetaSearch...
  }
  s.description = %q{
    This is just an extraction from Ransack/Squeel. You probably don't want to use this
    directly. It extends ActiveRecord's associations to support polymorphic belongs_to
    associations.
  }

  s.rubyforge_project = "polyamorous"

  s.add_dependency 'activerecord', '>= 4.2'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'machinist', '~> 1.0.6'
  s.add_development_dependency 'faker', '~> 1.6.5'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }  
  s.require_paths = ["lib"]
end
