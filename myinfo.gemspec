# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'myinfo/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.7'
  s.name        = 'myinfo'
  s.version     = MyInfo::Version::WRAPPER_VERSION
  s.summary     = 'Rails wrapper for MyInfo API'
  s.description = 'Rails wrapper for MyInfo API'
  s.authors     = ['Lim Yao Jie', 'Eileen Kang']
  s.email       = 'eileen_kang@tech.gov.sg'
  s.files       = Dir['lib/**/*.rb', 'README.md']
  s.homepage    = 'https://github.com/GovTechSG/myinfo-rails'
  s.license     = 'MIT'
  s.metadata    = { 'rubygems_mfa_required' => 'true' }

  # TODO: find an alternative for jose as it is not maintained
  s.add_runtime_dependency 'jose', '>= 1.1.3'
  s.add_runtime_dependency 'jwe', '~> 0.4'
  s.add_runtime_dependency 'jwt', '~> 2.7'
  s.add_development_dependency 'rails', '~> 7'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rspec-rails', '~> 4.0'
  s.add_development_dependency 'rubocop', '~> 1.59'
  s.add_development_dependency 'rubocop-rspec', '~> 2.25'
  s.add_development_dependency 'simplecov', '~> 0.21'
  s.add_development_dependency 'webmock', '~> 3.11'
end
