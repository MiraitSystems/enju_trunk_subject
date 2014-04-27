$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
#require "enju_subject/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_trunk_subject"
  s.version     = "1.0"
  s.authors     = ["MIS OSOL"]
  s.email       = ["tamiya.emiko@miraitsystems.jp"]
  s.homepage    = ""
  s.summary     = "enju_trunk_subject plugin"
  s.description = "Subject and classification management for EnjuTrunk"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids}/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "enju_core", "~> 0.1.1.pre3"
  s.add_dependency "inherited_resources"
  s.add_dependency "dynamic_form"
  s.add_dependency "nokogiri"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "vcr", "~> 2.4"
  s.add_development_dependency "enju_biblio", "~> 0.1.0.pre21"
  s.add_development_dependency "sunspot_solr", "~> 2.0.0"
  s.add_development_dependency "sunspot-rails-tester"

end
