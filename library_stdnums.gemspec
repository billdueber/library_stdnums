# encoding: utf-8


lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'library_stdnums/version'

Gem::Specification.new do |spec|
  spec.name          = "library_stdnums"
  spec.version       = StdNum::VERSION
  spec.authors       = ["Bill Dueber"]
  spec.email         = ["none@nowhere.org"]
  spec.summary       =  "A simple set of module functions to normalize, validate, and convert common library standard numbers"
  spec.homepage      = "https://github.com/billdueber/library_stdnums"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = spec.files.grep(%r{^doc/})

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "yard"
end


