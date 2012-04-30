$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_subject/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_subject"
  s.version     = EnjuSubject::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["tanabe@mwr.mediacom.keio.ac.jp"]
  s.homepage    = "https://github.com/nabeta/enju_subject"
  s.summary     = "enju_subject plugin"
  s.description = "Subject and classification management for Next-L Enju"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "friendly_id", "~> 4.0"
  s.add_dependency "will_paginate", "~> 3.0"
  s.add_dependency "devise"
  s.add_dependency "cancan"
  s.add_dependency "inherited_resources"
  s.add_dependency "attribute_normalizer", "~> 1.1"
  s.add_dependency "sunspot_rails"
  s.add_dependency "sunspot_solr"
  s.add_dependency "dynamic_form"
  s.add_dependency "acts_as_list", "~> 0.1.6"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "sunspot-rails-tester"
  s.add_development_dependency "vcr", "~> 2.1"
  s.add_development_dependency "fakeweb"
end
