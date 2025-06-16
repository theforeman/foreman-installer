source 'https://rubygems.org'

gem 'kafo', '>= 7.6', '< 8'
gem 'librarian-puppet', '>= 3.0'
gem 'openvox', "~> #{ENV.fetch('PUPPET_VERSION', '8.0')}"
gem 'openvox-strings'
gem 'rake'

if RUBY_VERSION >= '3.4'
  # https://github.com/OpenVoxProject/puppet/issues/90
  gem 'syslog'
end

gem 'semverse', groups: [:development, :test]

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 0.80.0'
end

group :development do
  # Dependencies for rake pin_modules
  gem 'puppet_forge'
  gem 'minitar', '< 1.0.0'
end
