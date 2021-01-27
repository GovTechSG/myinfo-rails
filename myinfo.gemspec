# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '~> 2.7'
  s.name        = 'myinfo'
  s.version     = '0.0.0'
  s.date        = '2020-01-18'
  s.summary     = 'MyInfo gem'
  s.description = 'Rails wrapper for MyInfo API'
  s.authors     = ['Lim Yao Jie']
  s.email       = 'limyaojie93@gmail.com'
  s.files       = Dir['lib/**/*.rb', 'README.md']
  s.homepage    =
    'https://rubygems.org/gems/myinfo'
  s.license = 'MIT'

  s.add_dependency 'jwe', '~> 0.4'
  s.add_dependency 'jwt', '~> 2.2'
  s.add_development_dependency 'rails', '~> 6.1'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rspec-rails', '~> 4.0'
  s.add_development_dependency 'rubocop', '~> 1.8'
  s.add_development_dependency 'simplecov', '~> 0.21'
  s.add_development_dependency 'webmock', '~> 3.11'
end
