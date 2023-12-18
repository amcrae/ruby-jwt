# frozen_string_literal: true

require 'rspec'
require 'simplecov'
require 'jwt'

# Avoid ffi>1.16 dependency in jruby<=9.1.17
if RUBY_VERSION > "2.5" then
  require 'pry'  
  if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby' then
    require 'pry-debugger-jruby'
  end
end

puts "OpenSSL::VERSION: #{OpenSSL::VERSION}"
puts "OpenSSL::OPENSSL_VERSION: #{OpenSSL::OPENSSL_VERSION}"
puts "OpenSSL::OPENSSL_LIBRARY_VERSION: #{OpenSSL::OPENSSL_LIBRARY_VERSION}\n\n"

CERT_PATH = File.join(__dir__, 'fixtures', 'certs')

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.before(:example) { ::JWT.configuration.reset! }
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
