# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'RubyBtce/version'

Gem::Specification.new do |spec|
  spec.name          = "RubyBtce"
  spec.version       = RubyBtce::VERSION
  spec.authors       = ["Brock Harris"]
  spec.email         = ["btharris781@gmail.com"]
  spec.summary       = "RubyBtce provides a simple and clean API wrapper for interfacing with the BTC-e API in a Rails app or CLI."
  spec.description   = "Supports all API methods and currency pairs."
  spec.homepage      = "https://github.com/BrockHarris/RubyBtce"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'json'
  spec.add_dependency 'hashie'
  spec.add_dependency 'httparty'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
