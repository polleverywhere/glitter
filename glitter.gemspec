# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "glitter/version"

Gem::Specification.new do |s|
  s.name        = "glitter"
  s.version     = Glitter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brad Gessler, Thomas Hanley"]
  s.email       = ["brad@polleverywhere.com, tom@lytro.com"]
  s.homepage    = "https://github.com/polleverywhere/glitter"
  s.summary     = %q{Publish Mac software updates with the Sparkle framework and Amazon S3.}
  s.description = %q{Glitter makes it easy to publish software updates via the Sparkle framework by using S3 buckets.}
  s.licenses    = ['MIT']

  s.required_ruby_version = ">= 2.0.0"
  s.add_dependency "s3", "~> 0.3"
  s.add_dependency "haml", "~> 5.0"
  s.add_dependency "thor", "~> 1.0"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
