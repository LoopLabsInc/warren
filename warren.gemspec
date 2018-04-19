# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warren/version'

Gem::Specification.new do |spec|
  spec.name          = "warren"
  spec.version       = Warren::VERSION
  spec.authors       = ["Dale Stevens"]
  spec.email         = ["dale@twilightcoders.net"]

  spec.summary       = %q{Intelligent RabbitMQ clustering}
  spec.description   = %q{Intelligent RabbitMQ clustering}
  spec.homepage      = "https://github.com/TwilightCoders/warren"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib', 'spec']

  spec.required_ruby_version = '>= 2.2'

  spec.add_runtime_dependency 'activesupport', ['>= 4', '< 6']
  spec.add_runtime_dependency 'erle'

  # Adapter Dependencies
  spec.add_runtime_dependency 'aws-sdk-core', '~> 3'
  spec.add_runtime_dependency 'aws-sdk-ec2', '~> 1'
  spec.add_runtime_dependency 'aws-sdk-ecs', '~> 1'

  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'factory_bot'

end
