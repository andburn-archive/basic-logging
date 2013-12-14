# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'basic_logging/version'

Gem::Specification.new do |spec|
  spec.name          = "basic_logging"
  spec.version       = BasicLogging::VERSION
  spec.authors       = ["Andrew Burnett"]
  spec.email         = ["andrew@andburn.com"]
  spec.description   = %q{A simple logging library.}
  spec.summary       = %q{A logging library allowing use of different file formats.}
  spec.homepage      = "https://github.com/andburn/basic_logging.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
