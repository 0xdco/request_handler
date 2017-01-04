# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/request_handler/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength:
  spec.name          = "dry-request_handler"
  spec.version       = Dry::RequestHandler::VERSION
  spec.authors       = ["Andreas Eger", "Raphael Hetzel"]
  spec.email         = ["andreas.eger@runtastic.com", "raphael.hetzel@runtastic.com"]

  spec.summary       = "shared base for request_handler using dry-* gems"
  spec.description   = "shared base for request_handler using dry-* gems"
  spec.homepage      = "https://git.example.com/projects/GEM/repos/dry-request_handler"
  spec.license       = "MIT"
  spec.required_ruby_version = "~> 2.2"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://gems.example.com"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-validation", "~> 0.10.4"
  spec.add_dependency "confstruct", "~> 1.0.2"
  spec.add_dependency "multi_json", "~> 1.12"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "fuubar", "~> 2.2"

  spec.add_development_dependency "rubocop_runner"
  spec.add_development_dependency "rubocop-defaults"
  spec.add_development_dependency "rubocop", "~> 0.46.0"
  spec.add_development_dependency "geminabox-release"

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-rubocop"
end
