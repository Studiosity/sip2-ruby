# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sip2/version'

Gem::Specification.new do |spec|
  spec.name          = 'sip2'
  spec.version       = Sip2::VERSION
  spec.authors       = ['abrom']
  spec.email         = ['a.bromwich@gmail.com']

  spec.summary       = 'SIP2 Ruby client'
  spec.description   = '3M™ Standard Interchange Protocol v2 client implementation in Ruby'
  spec.homepage      = 'https://github.com/Studiosity/sip2-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files lib`.split("\n") + %w[LICENSE README.md]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
  spec.add_development_dependency 'timecop', '~> 0.9'
end
