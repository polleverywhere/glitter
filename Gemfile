source "http://rubygems.org"

# Specify your gem's dependencies in glitter.gemspec
gemspec

group :development, :test do
  gem 'rspec'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'growl'
end