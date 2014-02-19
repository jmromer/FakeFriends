# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_friends/version'

Gem::Specification.new do |spec|
  spec.name          = "fake_friends"
  spec.version       = FakeFriends::VERSION
  spec.authors       = ["Jake Romer"]
  spec.email         = ["jacob.romer@icloud.com"]
  spec.description   = %q{A simple fake user generator}
  spec.summary       = %q{Generates fake users with consistent
                        attributes from public Twitter accounts
                        and image urls from uiFaces.com.}
  spec.homepage      = "http://github.com/jmromer/FakeFriends"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # TO BE ADDED
  # spec.add_runtime_dependency "twitter", "~> 5.6.0"

  spec.add_development_dependency "twitter", "~> 5.6.0"
  spec.add_development_dependency "rspec", "~> 2.14.1"

  spec.add_development_dependency "bundler", "~> 1.5.2"
  spec.add_development_dependency "rake", "~> 10.1.0"
end
