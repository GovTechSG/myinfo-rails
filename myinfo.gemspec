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

  s.add_dependency 'jwe', '~> 0.4'
  s.add_dependency 'jwt', '~> 2.2'
  s.add_development_dependency 'rails', '~> 6'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rspec-rails', '~> 4.0'
  s.add_development_dependency 'rubocop', '~> 1.8'
  s.add_development_dependency 'simplecov', '~> 0.21'
  s.add_development_dependency 'webmock', '~> 3.11'
end
