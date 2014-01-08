$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_subject/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_trunk_subject"
  s.version     = EnjuTrunkSubject::VERSION
  s.authors     = ["MIS OSOL"]
  s.email       = ["tamiya.emiko@miraitsystems.jp"]
  s.homepage    = ""
  s.summary     = "enju_trunk_subject plugin"
  s.description = "Subject and classification management for EnjuTrunk"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids}/*"]

end
