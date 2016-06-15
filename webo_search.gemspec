$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "webo_search/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webo_search"
  s.version     = WeboSearch::VERSION
  s.authors     = ["Amitkumar Jha"]
  s.email       = ["amit@weboniselab.com"]
  s.homepage    = "https://github.com/amitwebonise/webo_search"
  s.summary     = "Generic search plugin for Postgres Database."
  s.description = "Generic search plugin for Postgres Database.."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"

  s.add_development_dependency "pg"
end
