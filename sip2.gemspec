# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sip2/version'

Gem::Specification.new do |spec|
  spec.name          = 'sip2'
  spec.version       = Sip2::VERSION
  spec.authors       = ['abrom']
  spec.email         = ['a.bromwich@gmail.com']

  spec.summary       = '3M™ Standard Interchange Protocol v2 client implementation in Ruby'
  spec.description   = '3M™ Standard Interchange Protocol v2 client implementation in Ruby'
  spec.homepage      = 'https://github.com/TutoringAustralasia/sip2-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.48.1'
  spec.add_development_dependency 'timecop', '~> 0'
end
