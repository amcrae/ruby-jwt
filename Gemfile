# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'jruby-openssl', ">=0.14.2", platforms: [:jruby]

gem 'rubocop', '< 1.32' # Keep .codeclimate.yml channel in sync with this one

if RUBY_VERSION > "2.5" then
  group :development, :test do
    gem 'pry'
    gem 'pry-debugger-jruby', platforms: [:jruby]
  end  
end
