# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restful_resource_bugsnag/version'

Gem::Specification.new do |spec|
  spec.name          = "restful_resource_bugsnag"
  spec.version       = RestfulResourceBugsnag::VERSION
  spec.authors       = ["mwagg"]
  spec.email         = ["developers@carwow.co.uk"]

  spec.summary       = %q{A Bugsnag middleware which adds extra details to notifications for RestfulResource errors.}
  spec.description   = %q{A Bugsnag middleware which adds extra details to notifications for RestfulResource errors.}
  spec.homepage      = "https://github.com/carwow/restful_resource_bugsnag"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bugsnag", "~> 4.0", ">= 4.0.2"
  spec.add_dependency "restful_resource", "~> 0.10.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.0", ">= 2.0.3"
end
