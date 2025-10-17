source 'https://rubygems.org'

# rdoc 6.4 pulls in psych 4 and Puppet is incompatible with that.
# We don't want to list psych since that updates the bundled version
gem 'rdoc', '< 6.4'

gem 'kafo', '>= 7.6', '< 8'
gem 'librarian-puppet', '>= 3.0'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 8.0'
gem 'facter', '~> 4.1'

gem 'puppet-strings'
gem 'rake'

if RUBY_VERSION >= '3.4'
  gem 'base64'
  gem 'getoptlong'
  gem 'syslog'
  # can be removed when we release https://github.com/theforeman/kafo/pull/387 & https://github.com/theforeman/kafo_wizards/pull/13
  gem 'abbrev'
end
gem 'racc' if RUBY_VERSION >= '3.3'

gem 'semverse', groups: [:development, :test]

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 1.81.0'
end

group :development do
  # Dependencies for rake pin_modules
  gem 'puppet_forge'
  gem 'minitar', '< 1.0.0'
end
