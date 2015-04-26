# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'betfair/version'

Gem::Specification.new do |spec|
  spec.name          = "betfair-ng"
  spec.version       = Betfair::VERSION
  spec.authors       = ["Mike Campbell"]
  spec.email         = ["mike@wordofmike.net"]
  spec.summary       = %q{A lightweight wrapper for the Betfair Exchange API-NG}
  spec.homepage      = "http://github.com/mikecmpbll/betfair"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency 'activesupport', '> 3.0.0'
  spec.add_runtime_dependency 'httpi', '> 2.0.2'
end
